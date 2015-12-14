class Survey < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  has_many :answers, -> { order 'id asc' }, :dependent => :destroy
  has_many :response_comments
  has_many :responses, :through => :answers

  # alternative to responders:
  #User.find(Response.count(:conditions => {:answer_id => Survey.all.first.answer_ids}, :group => :user_id).keys)

  def responders
    sql = "select users.*
           from users
           left join responses on responses.user_id = users.id
           left join answers on responses.answer_id = answers.id
           left join surveys on answers.survey_id = surveys.id
           left join response_comments on response_comments.user_id = users.id
           where surveys.id = #{self.id}
           group by users.id"
    User.find_by_sql(sql)
  end

  def response_from?(user)
    not self.responders.select{ |u| u.id == user.id }.nil?
  end
  
  #def total_responses
  #  responders.count

    #total = 0
    #if responses_by_user = Response.count(:conditions => {:answer_id => answer_ids}, :group => :user_id)
    #  total += responses_by_user.count
    #end
    # add comments
    #if responses_by_user = ResponseComments.find_by_survey_id(id)
    #  total += responses_by_user.count
    #end
    #total
  #end
  
  def remove_response_by_user(user)
    Response.where(user_id: user.id, answer_id: answer_ids).each do |r|
      r.destroy
    end
    ResponseComment.where(user_id: user.id, survey_id: id).each do |r|
      r.destroy
    end
  end
  
  def is_valid?
    valid_until >= Time.now.to_date
  end
  
end
