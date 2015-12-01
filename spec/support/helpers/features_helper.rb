module FeaturesHelper
  def enter_prisoner_information
    fill_in 'Prisoner first name', with: 'Oscar'
    fill_in 'Prisoner last name', with: 'Wilde'
    fill_in 'Day', with: '31'
    fill_in 'Month', with: '12'
    fill_in 'Year', with: '1980'
    fill_in 'Prisoner number', with: 'a1234bc'
    select_prison 'Reading Gaol'
  end

  def enter_visitor_information(expected_email_address)
    within '#visitor-0' do
      fill_in 'Your first name', with: 'Ada'
      fill_in 'Your last name', with: 'Lovelace'
      fill_in 'Day', with: '30'
      fill_in 'Month', with: '11'
      fill_in 'Year', with: '1970'
      fill_in 'Email address', with: expected_email_address
      fill_in 'Phone number', with: '01154960222'
    end
  end

  def select_a_slot
    available_slots = all('#slots_step_option_0 option').map(&:text)
    select available_slots[1], from: 'Option 1'
    select available_slots[2], from: 'Option 1'
    select available_slots[3], from: 'Option 1'
  end

  def select_prison(name)
    find('input[data-input-name="prisoner_step[prison_id]"]').
      set(name)
  end
end
