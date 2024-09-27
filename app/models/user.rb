class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  belongs_to :app
  attr_accessor :app_tag

  validates :email, uniqueness: { scope: :app_id, message: "Email / app pair should be unique" }

  def will_save_change_to_email?
    false
  end 

end
