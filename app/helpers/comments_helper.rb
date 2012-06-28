module CommentsHelper

  def modified_string(comment)
    (comment.is_modified? ? "Last modified on " : "Posted on ") +
    comment.updated_at.strftime('%b %d %Y, %I:%M %p')
  end

end
