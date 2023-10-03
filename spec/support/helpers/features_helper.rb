module FeaturesHelper
  def select_from_chosen(item_text, options)
    field = find_field(options[:from], visible: false)
    find("##{field[:id]}_chosen").click
    find("##{field[:id]}_chosen ul.chosen-results li", text: item_text).click
  end

  def unselect_from_chosen(item_text, options)
    field = find_field(options[:from], visible: false)
    find("##{field[:id]}_chosen").click
    find("##{field[:id]}_chosen ul.chosen-choices li", text: item_text)
      .find("a.search-choice-close").click
  end
end
