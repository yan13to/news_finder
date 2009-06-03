function toggle_default_text(toggle, text_box_id, default_text) {
  var text_box_text = $(text_box_id).value;
  if (text_box_text == default_text && toggle == 'hide') {
    $(text_box_id).writeAttribute("value", "");
  };
  if (text_box_text == "" && toggle == 'show') {
    $(text_box_id).writeAttribute("value", default_text);
  };
  return false;
}