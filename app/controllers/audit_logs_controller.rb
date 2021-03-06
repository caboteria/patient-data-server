class AuditLogsController < ApplicationController
  
  # All attributes of the AuditLog class are valid to sort on except ones that start with an underscore.
  VALID_SORTABLE_COLUMNS = AuditLog.fields.keys.reject {|k| k[0] == '_'}
  VALID_SORT_ORDERS = ['desc', 'asc']
  

  ################
  ##
  def test
    ## test method for testing.  When called, application controller will log this method call and add an entry into the DB
    @audit_logs = []
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @audit_logs }
    end
  end


  ################
  ##
  def index
    order = []
    if VALID_SORTABLE_COLUMNS.include?(params[:sort]) && VALID_SORT_ORDERS.include?(params[:order])
      order << [params[:sort].to_sym, params[:order].to_sym]
    end

    # If no valid order is specified, order by date
    # If anything else is provided as a sort order, make date a secondary order
    if order.empty? || order[0][0] != :created_at
      order << [:created_at, :desc]
    end
    
    where = {}
    ##where[:username] = current_user.username unless current_user.admin?
    
    start_date = date_param_to_date(params[:log_start_date])
    if start_date
      where[:created_at] = {'$gte' => start_date}
    end
    
    end_date = date_param_to_date(params[:log_end_date])
    if end_date
      # will create an empty hash if created_at is nil or leave start_date alone if it is there
      where[:created_at] ||= {}
      where[:created_at].merge!('$lt' => end_date.next_day) # becomes less than midnight the next day
    end
    
    @audit_logs = AuditLog.where(where).order_by(order).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @audit_logs }
    end
    
  end


  ################
  ##
  def set_breadcrumbs
    super
    add_breadcrumb('Audit Log')
  end
  
  private
  
  def date_param_to_date(date_string)
    if date_string && date_string.split('/').length == 3
      split_date = date_string.split('/').map(&:to_i)
      Date.new(split_date[2], split_date[0], split_date[1])
    else
      nil
    end
  end
  
  #def validate_authorization!
  #  authorize! :read, Log
  #end
  
end
