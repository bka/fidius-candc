# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def truncate string, letters=40
    return string if (letters - 3) < 1 # Avoid empty string or array index out of bounds
    return string[0, letters-3] + '...' if string.length > letters
    string
  end
  
end
