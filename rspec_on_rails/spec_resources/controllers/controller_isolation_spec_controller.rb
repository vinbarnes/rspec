class ControllerIsolationSpecController < ActionController::Base
  set_view_path File.join(File.dirname(__FILE__), "..", "views")
  
  def some_action
    render :template => "template/that/does/not/actually/exist"
  end
  
  def action_with_template
    session[:session_key] = "session value"
    flash[:flash_key] = "flash value"
    render :template => "controller_isolation_spec/action_with_template"
  end
  
  def action_with_partial
    render :partial => "controller_isolation_spec/a_partial"
  end
  
  def action_with_errors_in_template
    render :template => "controller_isolation_spec/action_with_errors_in_template"
  end
end