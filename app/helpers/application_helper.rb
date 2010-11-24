# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def format_hex_str str
    i = 0
    res = ""
    str.each_char do |c|
      i += 1
      res << c
      if i%64 == 0
        res << "\n"
      elsif i%8 == 0
        res << ' '
      end
    end
    res
  end

end
