class MessagesController < ApplicationController
  
  before_filter :set_user
  
  def index
    @messages = Message.scoped
    @message = Message.new
    if params[:mailbox] == "sent"
      @messages = @user.sent_messages.paginate :per_page => 10, :page => params[:page], :order => "created_at DESC"
    elsif params[:mailbox] == "inbox"
      @messages = @user.received_messages.inbox.paginate :per_page => 10, :page => params[:page], :order => "created_at DESC"
        #elsif params[:mailbox] == "archived"
     # @messages = @user.archived_messages
    end
    if params[:mailbox] == "unread"
    @messages = @user.unread_messages.paginate :per_page => 10, :page => params[:page], :order => "created_at DESC"
  end
  if params[:mailbox] == "trash"
    @messages = @user.deleted_messages.paginate :per_page => 10, :page => params[:page], :order => "created_at DESC"
  end
  end
  
  def new
      @message = Message.new
      @message.conversation_id = params[:conversation_id]
    end

    def create
      @message = Message.new(params[:message])
      @message.sender_id = @user.id
      if @message.save
        flash[:notice] = "Message has been sent"
        redirect_to user_messages_path(current_user, :mailbox=>:inbox)
      else
        render :action => :new
      end
    end

    def show
      @messages = Message.where(conversation_id: params[:id]).order(created_at: :desc)
      @reply_message = Message.new
        @message = Message.find(params[:id])
        if @message.recipient == current_user
           UserMessageWorker.perform_async(@message.id, current_user.id)
         end
        @message.readingmessage if @message.recipient == current_user
      end

    def reply
        @message = Message.new
        @message.conversation_id = params[:conversation_id]
    end
  
  def askout
    @message = Message.new
  end
 
   def destroy
     @message = Message.find(params[:id])
     @message.destroy
     flash[:notice] = "Successfully deleted message."
     redirect_to user_messages_path(@user, @messages)
   end
  
  def delete_multiple
      if params[:delete]
        params[:delete].each { |id|
          @message = Message.find(id)
          @message.mark_message_deleted(@message.id,@user.id) unless @message.nil?
        }
        flash[:notice] = "Messages deleted"
      end
      redirect_to user_messages_path(@user, @messages)
  end
  
  
  def update
      @message = Message.new
      if params[:reply_to]
        @reply_to = User.find_by_id(params[:reply_to])
        unless @reply_to.nil?
          @message.recipient_id = @reply_to.id
        end
      end
    end
  
  private
    def set_user
      @user = current_user
  end
end