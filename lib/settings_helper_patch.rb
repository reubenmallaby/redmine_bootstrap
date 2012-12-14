require_dependency 'settings_helper'

module SettingsHelper
  alias_method :notification_field_without_bootstrap, :notification_field
  alias_method :setting_multiselect_without_bootstrap, :setting_multiselect

  def notification_field(notifiable)
    return content_tag(:label,
                       check_box_tag('settings[notified_events][]',
                                     notifiable.name,
                                     Setting.notified_events.include?(notifiable.name), :id => nil).html_safe +
                         l_or_humanize(notifiable.name, :prefix => 'label_').html_safe,
                       :class => "checkbox inline #{notifiable.parent.present? ? 'parent' : ''}").html_safe
  end

  def setting_multiselect(setting, choices, options={})
    setting_values = Setting.send(setting)
    setting_values = [] unless setting_values.is_a?(Array)

    content_tag("label", l(options[:label] || "setting_#{setting}")) +
      hidden_field_tag("settings[#{setting}][]", '').html_safe +
      choices.collect do |choice|
        text, value = (choice.is_a?(Array) ? choice : [choice, choice])
        content_tag(
          'label',
          check_box_tag(
             "settings[#{setting}][]",
             value,
             Setting.send(setting).include?(value),
             :id => nil
           ) + text.to_s,
          :class => 'checkbox block'
         )
      end.join.html_safe
  end
  
end
