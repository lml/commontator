class Commontator::Thread < ActiveRecord::Base
  belongs_to :closer, polymorphic: true, optional: true
  belongs_to :commontable, polymorphic: true, optional: true, inverse_of: :commontator_thread

  has_many :comments, dependent: :destroy, inverse_of: :thread
  has_many :subscriptions, dependent: :destroy, inverse_of: :thread

  validates :commontable, presence: true, unless: :is_closed?
  validates :commontable_id, uniqueness: { scope: :commontable_type, allow_nil: true }

  def config
    @config ||= commontable.try(:commontable_config) || Commontator
  end

  def will_paginate?
    !config.comments_per_page.nil?
  end

  def is_votable?
    config.comment_voting.to_sym != :n
  end

  def is_filtered?
    !config.comment_filter.nil?
  end

  def filtered_comments
    cf = config.comment_filter
    return comments if cf.nil?

    comments.where(cf)
  end

  def ordered_comments(show_all = false)
    vc = show_all ? comments : filtered_comments
    cc = Commontator::Comment.arel_table
    case config.comment_order.to_sym
    when :l
      vc.order(cc[:created_at].desc)
    when :e
      vc.order(cc[:created_at].asc)
    when :ve
      vc.order((cc[:cached_votes_down] - cc[:cached_votes_up]).asc, cc[:created_at].asc)
    when :vl
      vc.order((cc[:cached_votes_down] - cc[:cached_votes_up]).asc, cc[:created_at].desc)
    else
      vc
    end
  end

  def latest_comment(show_all = false)
    @latest_comment ||= ordered_comments(show_all).last
  end

  def paginated_comments(page = 1, show_all = false)
    oc = ordered_comments(show_all)
    return oc unless will_paginate?

    oc.paginate(page: page, per_page: config.comments_per_page)
  end

  def nest_comments(comments, num_children_by_parent_id, children_by_parent_id)
    comments.map do |comment|
      # Delete is used to ensure loops don't cause stack overflow
      [
        comment,
        num_children_by_parent_id.delete(comment.id) || 0,
        nest_comments(
          children_by_parent_id.delete(comment.id) || [],
          num_children_by_parent_id,
          children_by_parent_id
        )
      ]
    end
  end

  def nested_comments_for(user, comments = nil, parent_id = nil, page = 1, show_all = false)
    comments ||= paginated_comments(page, show_all)
    includes = [ :thread, :creator, :editor ]
    comments = comments.includes(includes)

    if [ :i, :b ].include? config.comment_reply_style
      root_comments = comments.where(parent_id: parent_id).to_a

      per_page = config.nested_comments_per_page || 0
      num_children_by_parent_id = {}
      all_descendant_ids = []
      root_comments.each do |comment|
        descendant_ids = comment.descendant_ids
        num_children_by_parent_id[comment.id] = descendant_ids.size
        all_descendant_ids += descendant_ids[((page - 1) * per_page)..(page * per_page)] || []
      end
      children_by_parent_id = ordered_comments(show_all)
        .where(id: all_descendant_ids.uniq)
        .order(:created_at)
        .includes(includes)
        .group_by(&:parent_id)

      nest_comments(root_comments, num_children_by_parent_id, children_by_parent_id)
    else
      comments.map { |comment| [ comment, 0, [] ] }
    end.tap do |nested_comments|
      next unless is_votable?

      all_comments = nested_comments.flatten.select { |comm| comm.is_a?(Commontator::Comment) }
      ActiveRecord::Associations::Preloader.new.preload(
        all_comments, :votes_for, ActsAsVotable::Vote.where(voter: user)
      )
    end
  end

  def new_comment_page
    per_page = config.comments_per_page.to_i
    return 1 if per_page <= 0

    comment_index = case config.comment_order.to_sym
    when :l
      1 # First comment
    when :ve
      cc = Commontator::Comment.arel_table
      # Last comment with rating == 0
      filtered_comments.where((cc[:cached_votes_up] - cc[:cached_votes_down]).gteq(0)).count
    when :vl
      cc = Commontator::Comment.arel_table
      # First comment with rating == 0
      filtered_comments.where((cc[:cached_votes_up] - cc[:cached_votes_down]).gt(0)).count + 1
    else
      filtered_comments.count # Last comment
    end

    (comment_index.to_f/per_page).ceil
  end

  def is_closed?
    !closed_at.nil?
  end

  def close(user = nil)
    return false if is_closed?

    self.closed_at = Time.now
    self.closer = user
    save
  end

  def reopen
    return false unless is_closed? && !commontable.nil?

    self.closed_at = nil
    save
  end

  def subscribers
    subscriptions.map(&:subscriber)
  end

  def subscription_for(subscriber)
    return nil if !subscriber || !subscriber.is_commontator

    subscriber.commontator_subscriptions.find_by(thread_id: self.id)
  end

  def subscribe(subscriber)
    return false unless subscriber.is_commontator && !subscription_for(subscriber)

    subscription = Commontator::Subscription.new
    subscription.subscriber = subscriber
    subscription.thread = self
    subscription.save
  end

  def unsubscribe(subscriber)
    subscription = subscription_for(subscriber)
    return false unless subscription

    subscription.destroy
  end

  def mark_as_read_for(subscriber)
    subscription = subscription_for(subscriber)
    return false unless subscription

    subscription.touch
  end

  # Creates a new empty thread and assigns it to the commontable
  # The old thread is kept in the database for archival purposes
  def clear
    return if commontable.nil? || !is_closed?

    new_thread = Commontator::Thread.new
    new_thread.commontable = commontable

    with_lock do
      self.commontable = nil
      save!
      new_thread.save!
      Commontator::Subscription.where(thread: self).update_all(thread_id: new_thread.id)
    end
  end

  ##################
  # Access Control #
  ##################

  # Reader capabilities (user can be nil or false)
  def can_be_read_by?(user)
    return true if can_be_edited_by?(user)

    !commontable.nil? && config.thread_read_proc.call(self, user)
  end

  # Thread moderator capabilities
  def can_be_edited_by?(user)
    !commontable.nil? && !user.nil? && user.is_commontator &&
    config.thread_moderator_proc.call(self, user)
  end

  def can_subscribe?(user)
    thread_sub = config.thread_subscription.to_sym
    !is_closed? && !user.nil? && user.is_commontator &&
    (thread_sub == :m || thread_sub == :b) && can_be_read_by?(user)
  end
end
