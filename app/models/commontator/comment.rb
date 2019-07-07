class Commontator::Comment < ActiveRecord::Base
  belongs_to :creator, polymorphic: true
  belongs_to :editor, polymorphic: true, optional: true
  belongs_to :thread, inverse_of: :comments
  belongs_to :parent, optional: true, class_name: name, inverse_of: :children

  has_many :children, class_name: name, inverse_of: :parent

  serialize :ancestor_ids, Commontator::JsonArrayCoder
  serialize :descendant_ids, Commontator::JsonArrayCoder

  validates :editor, presence: true, on: :update
  validates :body, presence: true, uniqueness: {
    scope: [ :creator_type, :creator_id, :thread_id, :deleted_at ], message: :double_posted
  }
  validate :parent_is_not_self, :parent_belongs_to_the_same_thread, if: :parent

  before_save :set_ancestor_ids_and_ancestor_descendant_ids
  before_destroy :remove_ancestor_descendant_ids

  cattr_accessor :will_paginate
  self.will_paginate = begin
    require 'will_paginate'

    true
  rescue LoadError
    false
  end

  cattr_accessor :is_votable
  self.is_votable = begin
    require 'acts_as_votable'
    acts_as_votable

    true
  rescue LoadError
    false
  end

  def self.will_paginate?
    will_paginate
  end

  def self.is_votable?
    is_votable
  end

  def is_modified?
    !editor.nil?
  end

  def is_latest?
    thread.comments.last == self
  end

  def get_vote_by(user)
    return nil unless self.class.is_votable? && !user.nil? && user.is_commontator

    votes_for.find_by(voter_type: user.class.name, voter_id: user.id)
  end

  def update_cached_votes(vote_scope = nil)
    self.update_column(:cached_votes_up, count_votes_up(true))
    self.update_column(:cached_votes_down, count_votes_down(true))
  end

  def is_deleted?
    !deleted_at.nil?
  end

  def delete_by(user)
    return false if is_deleted?

    self.deleted_at = Time.now
    self.editor = user
    self.save
  end

  def undelete_by(user)
    return false unless is_deleted?

    self.deleted_at = nil
    self.editor = user
    self.save
  end

  def created_timestamp
    I18n.t 'commontator.comment.status.created_at',
           created_at: I18n.l(created_at, format: :commontator)
  end

  def updated_timestamp
    I18n.t 'commontator.comment.status.updated_at',
           editor_name: Commontator.commontator_name(editor || creator),
           updated_at: I18n.l(updated_at, format: :commontator)
  end

  ##################
  # Access Control #
  ##################

  def can_be_created_by?(user)
    user == creator && !user.nil? && user.is_commontator &&
    !thread.is_closed? && thread.can_be_read_by?(user)
  end

  def can_be_edited_by?(user)
    return true if thread.can_be_edited_by?(user) &&
                   thread.config.moderator_permissions.to_sym == :e

    comment_edit = thread.config.comment_editing.to_sym
    !thread.is_closed? && !is_deleted? && user == creator && (editor.nil? || user == editor) &&
    comment_edit != :n && (is_latest? || comment_edit == :a) && thread.can_be_read_by?(user)
  end

  def can_be_deleted_by?(user)
    mod_perm = thread.config.moderator_permissions.to_sym
    return true if thread.can_be_edited_by?(user) && (mod_perm == :e || mod_perm == :d)

    comment_del = thread.config.comment_deletion.to_sym
    !thread.is_closed? && user == creator && (!is_deleted? || editor == user) &&
    comment_del != :n && (is_latest? || comment_del == :a) && thread.can_be_read_by?(user)
  end

  def can_be_voted_on?
    !thread.is_closed? && !is_deleted? &&
    thread.config.comment_voting.to_sym != :n && self.class.is_votable?
  end

  def can_be_voted_on_by?(user)
    !user.nil? && user.is_commontator && user != creator &&
    thread.can_be_read_by?(user) && can_be_voted_on?
  end

  protected

  # These 2 validation messages are not currently translated because end users should never see them
  def parent_is_not_self
    return if parent != self
    errors.add :parent, 'must be a different comment'
    throw :abort
  end

  def parent_belongs_to_the_same_thread
    return if parent.thread_id == thread_id
    errors.add :parent, 'must belong to the same thread'
    throw :abort
  end

  def remove_ancestor_descendant_ids
    return if ancestor_ids.empty?

    # Remove id and descendant_ids from ancestors
    self.class.where(id: ancestor_ids).order(:id).update_all("descendant_ids = #{
      ([ id ] + descendant_ids).reduce(self.class.arel_table[:descendant_ids]) do |memo, descendant_id|
        Arel::Nodes::NamedFunction.new('REPLACE', [
          Arel::Nodes::NamedFunction.new('REPLACE', [
            Arel::Nodes::NamedFunction.new('REPLACE', [
              Arel::Nodes::NamedFunction.new('REPLACE', [
                memo, Arel::Nodes.build_quoted("[#{descendant_id}]"), Arel::Nodes.build_quoted('[]')
              ]), Arel::Nodes.build_quoted("[#{descendant_id},"), Arel::Nodes.build_quoted('[')
            ]), Arel::Nodes.build_quoted(",#{descendant_id},"), Arel::Nodes.build_quoted(',')
          ]), Arel::Nodes.build_quoted(",#{descendant_id}]"), Arel::Nodes.build_quoted(']')
        ])
      end.to_sql
    }")

    association(:parent).reset
  end

  def set_ancestor_ids_and_ancestor_descendant_ids
    return if ancestor_ids.first == parent_id

    pa = parent

    remove_ancestor_descendant_ids

    # Remove ancestor_ids from descendants
    unless ancestor_ids.empty? || descendant_ids.empty?
      self.class.where(id: descendant_ids).order(:id).update_all("ancestor_ids = #{
        ancestor_ids.reduce(self.class.arel_table[:ancestor_ids]) do |memo, ancestor_id|
          Arel::Nodes::NamedFunction.new('REPLACE', [
            Arel::Nodes::NamedFunction.new('REPLACE', [
              Arel::Nodes::NamedFunction.new('REPLACE', [
                Arel::Nodes::NamedFunction.new('REPLACE', [
                  memo, Arel::Nodes.build_quoted("[#{ancestor_id}]"), Arel::Nodes.build_quoted('[]')
                ]), Arel::Nodes.build_quoted("[#{ancestor_id},"), Arel::Nodes.build_quoted('[')
              ]), Arel::Nodes.build_quoted(",#{ancestor_id},"), Arel::Nodes.build_quoted(',')
            ]), Arel::Nodes.build_quoted(",#{ancestor_id}]"), Arel::Nodes.build_quoted(']')
          ])
        end.to_sql
      }")

      children.reset
    end

    if pa.nil?
      self.ancestor_ids = []
    else
      self.ancestor_ids = [ pa.id ] + pa.ancestor_ids

      # Add id and descendant_ids to ancestors
      descendant_ids_str = ([ id ] + descendant_ids).to_json[1..-2]
      self.class.where(id: ancestor_ids).order(:id).update_all("descendant_ids = #{
        Arel::Nodes::NamedFunction.new('REPLACE', [
          Arel::Nodes::NamedFunction.new('REPLACE', [
            Arel::Nodes::NamedFunction.new('COALESCE', [
              self.class.arel_table[:descendant_ids], Arel::Nodes.build_quoted('[]')
            ]), Arel::Nodes.build_quoted(']'), Arel::Nodes.build_quoted(",#{descendant_ids_str}]")
          ]), Arel::Nodes.build_quoted('[,'), Arel::Nodes.build_quoted('[')
        ]).to_sql
      }")

      association(:parent).reset

      # Add ancestor_ids to descendants
      unless descendant_ids.empty?
        ancestor_ids_str = ancestor_ids.to_json[1..-2]
        self.class.where(id: descendant_ids).order(:id).update_all("ancestor_ids = #{
          Arel::Nodes::NamedFunction.new('REPLACE', [
            Arel::Nodes::NamedFunction.new('REPLACE', [
              Arel::Nodes::NamedFunction.new('COALESCE', [
                self.class.arel_table[:ancestor_ids], Arel::Nodes.build_quoted('[]')
              ]), Arel::Nodes.build_quoted(']'), Arel::Nodes.build_quoted(",#{ancestor_ids_str}]")
            ]), Arel::Nodes.build_quoted('[,'), Arel::Nodes.build_quoted('[')
          ]).to_sql
        }")

        children.reset
      end
    end
  end
end
