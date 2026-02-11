function drawPad_analog()
    xc = Panel.w / 2;

    draw_set_color(color_icon)
    draw_line_round(xc - ui(116), ui( 96), xc - ui(320), ui( 96), 2)
    draw_line_round(xc + ui( 71), ui(148), xc + ui(320), ui(148), 2)

    draw_text_set_format(4)
    lana_w = math.max(string_width(lana_node .. " " .. lana_valueKey) + ui(16), ui(64))
    lana_h = ui(24)
    lana_x = xc - ui(320)
    lana_y = ui(96 - 4) - lana_h

    rana_w = math.max(string_width(rana_node .. " " .. rana_valueKey) + ui(16), ui(64))
    rana_h = ui(24)
    rana_x = xc + ui(320) - rana_w
    rana_y = ui(148 - 4) - rana_h

    if(point_in_rectangle(Panel.mouse[1], Panel.mouse[2], lana_x, lana_y, lana_x + lana_w, lana_y + lana_h) == 1) then
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, lana_x, lana_y, lana_w, lana_h, c_white, 1)
        if(not lana_drag and mouse_check_button_pressed(mb_left) == 1) then
            drag_sx = Panel.mouseUI[1]
            drag_sy = Panel.mouseUI[2]
            lana_drag = true
        end
    else
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, lana_x, lana_y, lana_w, lana_h, color_white, 1)
    end

    if(point_in_rectangle(Panel.mouse[1], Panel.mouse[2], rana_x, rana_y, rana_x + rana_w, rana_y + rana_h) == 1) then
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, rana_x, rana_y, rana_w, rana_h, c_white, 1)
        if(not rana_drag and mouse_check_button_pressed(mb_left) == 1) then
            drag_sx = Panel.mouseUI[1]
            drag_sy = Panel.mouseUI[2]
            rana_drag = true
        end
    else
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, rana_x, rana_y, rana_w, rana_h, color_white, 1)
    end

    draw_text_set_format(4)
    draw_set_halign(fa_left)
    draw_set_valign(fa_center)

    draw_set_color(color_text)
    draw_text(lana_x + ui(8), lana_y + lana_h / 2, lana_node)
    draw_text(rana_x + ui(8), rana_y + rana_h / 2, rana_node)

    draw_set_color(color_text_sub)
    draw_text(lana_x + ui(8) + string_width(lana_node .. " "), lana_y + lana_h / 2, lana_valueKey)
    draw_text(rana_x + ui(8) + string_width(rana_node .. " "), rana_y + rana_h / 2, rana_valueKey)
end

function drawPad_button(menu_y)
    xc = Panel.w / 2;

    bx = xc + ui(80)
    draw_sprite_ext(s_controller_button, 0, bx, ui(72 + 48 * 0), ui(1), ui(1), 0, color_icon, 1)
    draw_sprite_ext(s_controller_button, 1, bx, ui(72 + 48 * 1), ui(1), ui(1), 0, color_icon, 1)
    draw_sprite_ext(s_controller_button, 2, bx, ui(72 + 48 * 2), ui(1), ui(1), 0, color_icon, 1)
    draw_sprite_ext(s_controller_button, 3, bx, ui(72 + 48 * 3), ui(1), ui(1), 0, color_icon, 1)

    draw_text_set_format(4)
    
    btx_w = math.max(string_width(btx_node .. " " .. btx_valueKey) + ui(16), ui(64))
    btx_h = ui(24)
    btx_x = bx + ui(32)
    btx_y = ui(72 + 48 * 0) - btx_h / 2

    if(point_in_rectangle(Panel.mouse[1], Panel.mouse[2], btx_x, btx_y, btx_x + btx_w, btx_y + btx_h) == 1) then
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, btx_x, btx_y, btx_w, btx_h, c_white, 1)
        if(not btx_drag and mouse_check_button_pressed(mb_left) == 1) then
            drag_sx = Panel.mouseUI[1]
            drag_sy = Panel.mouseUI[2]
            btx_drag = true
        end
    else
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, btx_x, btx_y, btx_w, btx_h, color_white, 1)
    end
    
    bty_w = math.max(string_width(bty_node .. " " .. bty_valueKey) + ui(16), ui(64))
    bty_h = ui(24)
    bty_x = bx + ui(32)
    bty_y = ui(72 + 48 * 1) - bty_h / 2

    if(point_in_rectangle(Panel.mouse[1], Panel.mouse[2], bty_x, bty_y, bty_x + bty_w, bty_y + bty_h) == 1) then
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, bty_x, bty_y, bty_w, bty_h, c_white, 1)
        if(not bty_drag and mouse_check_button_pressed(mb_left) == 1) then
            drag_sx = Panel.mouseUI[1]
            drag_sy = Panel.mouseUI[2]
            bty_drag = true
        end
    else
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, bty_x, bty_y, bty_w, bty_h, color_white, 1)
    end
    
    bta_w = math.max(string_width(bta_node .. " " .. bta_valueKey) + ui(16), ui(64))
    bta_h = ui(24)
    bta_x = bx + ui(32)
    bta_y = ui(72 + 48 * 2) - bta_h / 2

    if(point_in_rectangle(Panel.mouse[1], Panel.mouse[2], bta_x, bta_y, bta_x + bta_w, bta_y + bta_h) == 1) then
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, bta_x, bta_y, bta_w, bta_h, c_white, 1)
        if(not bta_drag and mouse_check_button_pressed(mb_left) == 1) then
            drag_sx = Panel.mouseUI[1]
            drag_sy = Panel.mouseUI[2]
            bta_drag = true
        end
    else
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, bta_x, bta_y, bta_w, bta_h, color_white, 1)
    end
    
    btb_w = math.max(string_width(btb_node .. " " .. btb_valueKey) + ui(16), ui(64))
    btb_h = ui(24)
    btb_x = bx + ui(32)
    btb_y = ui(72 + 48 * 3) - btb_h / 2

    if(point_in_rectangle(Panel.mouse[1], Panel.mouse[2], btb_x, btb_y, btb_x + btb_w, btb_y + btb_h) == 1) then
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, btb_x, btb_y, btb_w, btb_h, c_white, 1)
        if(not btb_drag and mouse_check_button_pressed(mb_left) == 1) then
            drag_sx = Panel.mouseUI[1]
            drag_sy = Panel.mouseUI[2]
            btb_drag = true
        end
    else
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, btb_x, btb_y, btb_w, btb_h, color_white, 1)
    end
    
    draw_text_set_format(4)
    draw_set_halign(fa_left)
    draw_set_valign(fa_center)

    draw_set_color(color_text)
    draw_text(btx_x + ui(8), btx_y + btx_h / 2, btx_node)
    draw_text(bty_x + ui(8), bty_y + bty_h / 2, bty_node)
    draw_text(bta_x + ui(8), bta_y + bta_h / 2, bta_node)
    draw_text(btb_x + ui(8), btb_y + btb_h / 2, btb_node)

    draw_set_color(color_text_sub)
    draw_text(btx_x + ui(8) + string_width(btx_node .. " "), btx_y + btx_h / 2, btx_valueKey)
    draw_text(bty_x + ui(8) + string_width(bty_node .. " "), bty_y + bty_h / 2, bty_valueKey)
    draw_text(bta_x + ui(8) + string_width(bta_node .. " "), bta_y + bta_h / 2, bta_valueKey)
    draw_text(btb_x + ui(8) + string_width(btb_node .. " "), btb_y + btb_h / 2, btb_valueKey)
end

function drawPad_dpad(menu_y)
    xc = Panel.w / 2;

    bx = xc + ui(80)
    draw_sprite_ext(s_controller_dpad_axis, 0, bx, ui(72 + 48 * 1), ui(1), ui(1), 0, color_icon, 1)
    draw_sprite_ext(s_controller_dpad_axis, 1, bx, ui(72 + 48 * 2), ui(1), ui(1), 0, color_icon, 1)

    draw_text_set_format(4)
    
    pdh_w = math.max(string_width(pdh_node .. " " .. pdh_valueKey) + ui(16), ui(64))
    pdh_h = ui(24)
    pdh_x = bx + ui(32)
    pdh_y = ui(72 + 48 * 1) - pdh_h / 2

    if(point_in_rectangle(Panel.mouse[1], Panel.mouse[2], pdh_x, pdh_y, pdh_x + pdh_w, pdh_y + pdh_h) == 1) then
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, pdh_x, pdh_y, pdh_w, pdh_h, c_white, 1)
        if(not pdh_drag and mouse_check_button_pressed(mb_left) == 1) then
            drag_sx = Panel.mouseUI[1]
            drag_sy = Panel.mouseUI[2]
            pdh_drag = true
        end
    else
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, pdh_x, pdh_y, pdh_w, pdh_h, color_white, 1)
    end
    
    pdv_w = math.max(string_width(pdv_node .. " " .. pdv_valueKey) + ui(16), ui(64))
    pdv_h = ui(24)
    pdv_x = bx + ui(32)
    pdv_y = ui(72 + 48 * 2) - pdv_h / 2

    if(point_in_rectangle(Panel.mouse[1], Panel.mouse[2], pdv_x, pdv_y, pdv_x + pdv_w, pdv_y + pdv_h) == 1) then
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, pdv_x, pdv_y, pdv_w, pdv_h, c_white, 1)
        if(not pdv_drag and mouse_check_button_pressed(mb_left) == 1) then
            drag_sx = Panel.mouseUI[1]
            drag_sy = Panel.mouseUI[2]
            pdv_drag = true
        end
    else
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, pdv_x, pdv_y, pdv_w, pdv_h, color_white, 1)
    end
    
    draw_text_set_format(4)
    draw_set_halign(fa_left)
    draw_set_valign(fa_center)

    draw_set_color(color_text)
    draw_text(pdh_x + 8, pdh_y + pdh_h / 2, pdh_node)
    draw_text(pdv_x + 8, pdv_y + pdv_h / 2, pdv_node)

    draw_set_color(color_text_sub)
    draw_text(pdh_x + 8 + string_width(pdh_node .. " "), pdh_y + pdh_h / 2, pdh_valueKey)
    draw_text(pdv_x + 8 + string_width(pdv_node .. " "), pdv_y + pdv_h / 2, pdv_valueKey)
end

function drawPad_trigger(menu_y)
    xc = Panel.w / 2;

    draw_set_color(color_icon)
    draw_line_round(xc + ui(116), ui( 96), xc + ui(320), ui( 96), 2)
    draw_line_round(xc - ui(116), ui( 96), xc - ui(320), ui( 96), 2)

    draw_line_round(xc + ui(132), ui(160), xc + ui(320), ui(160), 2)
    draw_line_round(xc - ui(132), ui(160), xc - ui(320), ui(160), 2)

    trl_w = math.max(string_width(trl_node .. " " .. trl_valueKey) + ui(16), ui(64))
    trl_h = ui(24)
    trl_x = xc - ui(320)
    trl_y = ui(96 - 4) - trl_h

    draw_text_set_format(4)

    if(point_in_rectangle(Panel.mouse[1], Panel.mouse[2], trl_x, trl_y, trl_x + trl_w, trl_y + trl_h) == 1) then
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, trl_x, trl_y, trl_w, trl_h, c_white, 1)
        if(not trl_drag and mouse_check_button_pressed(mb_left) == 1) then
            drag_sx = Panel.mouseUI[1]
            drag_sy = Panel.mouseUI[2]
            trl_drag = true
        end
    else
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, trl_x, trl_y, trl_w, trl_h, color_white, 1)
    end
    
    trlb_w = math.max(string_width(trlb_node .. " " .. trlb_valueKey) + ui(16), ui(64))
    trlb_h = ui(24)
    trlb_x = xc - ui(320)
    trlb_y = ui(160 - 4) - trlb_h

    if(point_in_rectangle(Panel.mouse[1], Panel.mouse[2], trlb_x, trlb_y, trlb_x + trlb_w, trlb_y + trlb_h) == 1) then
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, trlb_x, trlb_y, trlb_w, trlb_h, c_white, 1)
        if(not trlb_drag and mouse_check_button_pressed(mb_left) == 1) then
            drag_sx = Panel.mouseUI[1]
            drag_sy = Panel.mouseUI[2]
            trlb_drag = true
        end
    else
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, trlb_x, trlb_y, trlb_w, trlb_h, color_white, 1)
    end
    
    trr_w = math.max(string_width(trr_node .. " " .. trr_valueKey) + ui(16), ui(64))
    trr_h = ui(24)
    trr_x = xc + ui(320) - trr_w
    trr_y = ui(96 - 4) - trr_h

    if(point_in_rectangle(Panel.mouse[1], Panel.mouse[2], trr_x, trr_y, trr_x + trr_w, trr_y + trr_h) == 1) then
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, trr_x, trr_y, trr_w, trr_h, c_white, 1)
        if(not trr_drag and mouse_check_button_pressed(mb_left) == 1) then
            drag_sx = Panel.mouseUI[1]
            drag_sy = Panel.mouseUI[2]
            trr_drag = true
        end
    else
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, trr_x, trr_y, trr_w, trr_h, color_white, 1)
    end
    
    trrb_w = math.max(string_width(trrb_node .. " " .. trrb_valueKey) + ui(16), ui(64))
    trrb_h = ui(24)
    trrb_x = xc + ui(320) - trrb_w
    trrb_y = ui(160 - 4) - trrb_h

    if(point_in_rectangle(Panel.mouse[1], Panel.mouse[2], trrb_x, trrb_y, trrb_x + trrb_w, trrb_y + trrb_h) == 1) then
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, trrb_x, trrb_y, trrb_w, trrb_h, c_white, 1)
        if(not trrb_drag and mouse_check_button_pressed(mb_left) == 1) then
            drag_sx = Panel.mouseUI[1]
            drag_sy = Panel.mouseUI[2]
            trrb_drag = true
        end
    else
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, trrb_x, trrb_y, trrb_w, trrb_h, color_white, 1)
    end
    
    draw_set_halign(fa_left)
    draw_set_valign(fa_center)

    draw_set_color(color_text)
    draw_text(trl_x  + ui(8), trl_y  + trl_h  / 2, trl_node)
    draw_text(trlb_x + ui(8), trlb_y + trlb_h / 2, trlb_node)
    draw_text(trr_x  + ui(8), trr_y  + trr_h  / 2, trr_node)
    draw_text(trrb_x + ui(8), trrb_y + trrb_h / 2, trrb_node)

    draw_set_color(color_text_sub)
    draw_text(trl_x  + ui(8) + string_width(trl_node .. " "),  trl_y  + trl_h  / 2, trl_valueKey)
    draw_text(trlb_x + ui(8) + string_width(trlb_node .. " "), trlb_y + trlb_h / 2, trlb_valueKey)
    draw_text(trr_x  + ui(8) + string_width(trr_node .. " "),  trr_y  + trr_h  / 2, trr_valueKey)
    draw_text(trrb_x + ui(8) + string_width(trrb_node .. " "), trrb_y + trrb_h / 2, trrb_valueKey)
end

function drawPad()
    l_haxis = gamepad_axis_value(0, gp_axislh);
    l_vaxis = gamepad_axis_value(0, gp_axislv);
    r_haxis = gamepad_axis_value(0, gp_axisrh);
    r_vaxis = gamepad_axis_value(0, gp_axisrv);

    l_active = math.sqrt(l_haxis * l_haxis + l_vaxis * l_vaxis) >= deadZone
    r_active = math.sqrt(r_haxis * r_haxis + r_vaxis * r_vaxis) >= deadZone

    l_c = color_icon
    r_c = color_icon

    ctr_cx = Panel.w / 2
    
    if(setting_page == 1) then
        ctr_cx = ctr_cx - ui(160)
    elseif(setting_page == 2) then
        ctr_cx = ctr_cx - ui(160)
    end

    ctr_x = ctr_cx - ui(240)

    l_knx = ctr_x + ui(150.5)
    l_kny = ui(94.5)

    r_knx = ctr_x + ui(286)
    r_kny = ui(148.5)

    if(l_active) then
        l_c = c_white
        l_knx = l_knx + l_haxis * ui(20)
        l_kny = l_kny + l_vaxis * ui(20)
    end

    if(r_active) then
        r_c = c_white
        r_knx = r_knx + r_haxis * ui(20)
        r_kny = r_kny + r_vaxis * ui(20)
    end

    ar_u = gamepad_button_check(0, gp_padu) == 1
    ar_l = gamepad_button_check(0, gp_padl) == 1
    ar_d = gamepad_button_check(0, gp_padd) == 1
    ar_r = gamepad_button_check(0, gp_padr) == 1

    bt_x = gamepad_button_check(0, gp_face3) == 1
    bt_y = gamepad_button_check(0, gp_face4) == 1
    bt_a = gamepad_button_check(0, gp_face1) == 1
    bt_b = gamepad_button_check(0, gp_face2) == 1

    ar_u_c = color_icon
    ar_l_c = color_icon
    ar_d_c = color_icon
    ar_r_c = color_icon

    bt_x_c = color_icon
    bt_y_c = color_icon
    bt_a_c = color_icon
    bt_b_c = color_icon

    if(ar_u) then ar_u_c = c_white end
    if(ar_l) then ar_l_c = c_white end
    if(ar_d) then ar_d_c = c_white end
    if(ar_r) then ar_r_c = c_white end
    if(bt_x) then bt_x_c = c_white end
    if(bt_y) then bt_y_c = c_white end
    if(bt_a) then bt_a_c = c_white end
    if(bt_b) then bt_b_c = c_white end
    
    draw_sprite_ext(s_controller_arrow, 0, ctr_x + ui(193.4), ui(152.15), ui(1), ui(1), 0, ar_u_c, 1)
    draw_sprite_ext(s_controller_arrow, 1, ctr_x + ui(193.4), ui(152.15), ui(1), ui(1), 0, ar_l_c, 1)
    draw_sprite_ext(s_controller_arrow, 2, ctr_x + ui(193.4), ui(152.15), ui(1), ui(1), 0, ar_d_c, 1)
    draw_sprite_ext(s_controller_arrow, 3, ctr_x + ui(193.4), ui(152.15), ui(1), ui(1), 0, ar_r_c, 1)

    draw_sprite_ext(s_controller_button, 0, ctr_x + ui(305.5), ui( 95.5), ui(1), ui(1), 0, bt_x_c, 1)
    draw_sprite_ext(s_controller_button, 1, ctr_x + ui(329.5), ui( 71.5), ui(1), ui(1), 0, bt_y_c, 1)
    draw_sprite_ext(s_controller_button, 2, ctr_x + ui(329.5), ui(119.5), ui(1), ui(1), 0, bt_a_c, 1)
    draw_sprite_ext(s_controller_button, 3, ctr_x + ui(355.0), ui( 95.5), ui(1), ui(1), 0, bt_b_c, 1)

    draw_sprite_ext(s_controller, 0, ctr_cx, 0, ui(1), ui(1), 0, color_icon, 1)

    draw_sprite_ext(s_controller_knob, 0, l_knx, l_kny, ui(1), ui(1), 0, color_dkgrey, 1)
    draw_sprite_ext(s_controller_knob, 0, r_knx, r_kny, ui(1), ui(1), 0, color_dkgrey, 1)

    draw_sprite_ext(s_controller_knob, 1, l_knx, l_kny, ui(1), ui(1), 0, l_c, 1)
    draw_sprite_ext(s_controller_knob, 1, r_knx, r_kny, ui(1), ui(1), 0, r_c, 1)

    if(setting_page == 0) then
        drawPad_analog()
    elseif(setting_page == 1) then
        drawPad_button()
    elseif(setting_page == 2) then
        drawPad_dpad()
    end
end

function drawPadTop()
    sh_l  = gamepad_button_check(0, gp_shoulderr)  == 1
    sh_lb = gamepad_button_check(0, gp_shoulderrb) == 1
    sh_r  = gamepad_button_check(0, gp_shoulderl)  == 1
    sh_rb = gamepad_button_check(0, gp_shoulderlb) == 1

    sh_l_c  = color_icon
    sh_lb_c = color_icon
    sh_r_c  = color_icon
    sh_rb_c = color_icon

    if(sh_l)  then sh_l_c  = c_white end
    if(sh_lb) then sh_lb_c = c_white end
    if(sh_r)  then sh_r_c  = c_white end
    if(sh_rb) then sh_rb_c = c_white end

    ctr_x = Panel.w / 2

    draw_sprite_ext(s_controller_trigger, 0, ctr_x + ui(130.0), ui(106.0), ui(1), ui(1), 0, sh_l_c,  1)
    draw_sprite_ext(s_controller_trigger, 1, ctr_x + ui(156.0), ui(145.5), ui(1), ui(1), 0, sh_lb_c, 1)

    draw_sprite_ext(s_controller_trigger, 0, ctr_x - ui(130.0), ui(106.0), ui(-1), ui(1), 0, sh_r_c,  1)
    draw_sprite_ext(s_controller_trigger, 1, ctr_x - ui(156.0), ui(145.5), ui(-1), ui(1), 0, sh_rb_c, 1)

    draw_sprite_ext(s_controller, 1, Panel.w / 2, 0, ui(1), ui(1), 0, color_icon, 1)

    draw_set_halign(fa_center)
    draw_set_valign(fa_center)

    draw_set_color(color_text_sub)
    draw_text(Panel.w / 2, ui(200), "Mirrored")

    drawPad_trigger()
end

function drawSettings_analog(menu_y)
    xc = Panel.w / 2;

    draw_set_color(color_icon_dark)
    draw_roundrect_ext(     ui(8), menu_y - ui(20),      xc - ui(4), menu_y + ui(8 + 40 * 2), 4, 4, true)
    draw_roundrect_ext(xc + ui(4), menu_y - ui(20), Panel.w - ui(8), menu_y + ui(8 + 40 * 2), 4, 4, true)

    draw_text_set_format(3)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_text(     ui(16), menu_y - ui(20 - 2), "Left analog")
    draw_text(xc + ui(12), menu_y - ui(20 - 2), "Right analog")

    draw_set_valign(fa_center)
    draw_text_set_format(1)
    draw_text(     ui(16), menu_y + ui(8 + 40 * 0 + 16), "Offset")
    draw_text(     ui(16), menu_y + ui(8 + 40 * 1 + 16), "Scale")
    draw_text(xc + ui(12), menu_y + ui(8 + 40 * 0 + 16), "Offset")
    draw_text(xc + ui(12), menu_y + ui(8 + 40 * 1 + 16), "Scale")

    draw_text(     ui(16), menu_y + ui(20 + 40 * 2 + 16), "Deadzone")

    tb_lana_Center.draw(tb_lana_Center,          ui(100), menu_y + ui(8 + 40 * 0), xc - ui(10 + 100), ui(32), lana_center)
    tb_lana_Scale.draw(tb_lana_Scale,            ui(100), menu_y + ui(8 + 40 * 1), xc - ui(10 + 100), ui(32), lana_scale)

    tb_rana_Center.draw(tb_rana_Center, xc + ui(100 - 4), menu_y + ui(8 + 40 * 0), xc - ui(10 + 100), ui(32), rana_center)
    tb_rana_Scale.draw(tb_rana_Scale,   xc + ui(100 - 4), menu_y + ui(8 + 40 * 1), xc - ui(10 + 100), ui(32), rana_scale)

    tbDead.draw(tbDead,     ui(100), menu_y + ui(20 + 40 * 2), Panel.w - ui(8 + 100), ui(32), deadZone)
end

function drawSettings_button(menu_y)
    x0 = Panel.w / 4 * 1;
    x1 = Panel.w / 4 * 2;
    x2 = Panel.w / 4 * 3;
    x3 = Panel.w / 4 * 4;

    draw_set_color(color_icon_dark)
    draw_roundrect_ext(      ui(8), menu_y - ui(20), x0 - ui(4), menu_y + ui(88), ui(4), ui(4), true)
    draw_roundrect_ext( x0 + ui(4), menu_y - ui(20), x1 - ui(4), menu_y + ui(88), ui(4), ui(4), true)
    draw_roundrect_ext( x1 + ui(4), menu_y - ui(20), x2 - ui(4), menu_y + ui(88), ui(4), ui(4), true)
    draw_roundrect_ext( x2 + ui(4), menu_y - ui(20), x3 - ui(8), menu_y + ui(88), ui(4), ui(4), true)

    draw_text_set_format(3)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_text(      ui(8 + 8), menu_y - ui(20 - 2), "X button")
    draw_text( x0 + ui(4 + 8), menu_y - ui(20 - 2), "Y button")
    draw_text( x1 + ui(4 + 8), menu_y - ui(20 - 2), "A button")
    draw_text( x2 + ui(4 + 8), menu_y - ui(20 - 2), "B button")

    draw_set_valign(fa_center)
    draw_text_set_format(1)
    draw_text(      ui(8 + 8), menu_y + ui(8 + 40 * 0 + 16), "Unpressed")
    draw_text(      ui(8 + 8), menu_y + ui(8 + 40 * 1 + 16), "Pressed")
    draw_text( x0 + ui(4 + 8), menu_y + ui(8 + 40 * 0 + 16), "Unpressed")
    draw_text( x0 + ui(4 + 8), menu_y + ui(8 + 40 * 1 + 16), "Pressed")
    draw_text( x1 + ui(4 + 8), menu_y + ui(8 + 40 * 0 + 16), "Unpressed")
    draw_text( x1 + ui(4 + 8), menu_y + ui(8 + 40 * 1 + 16), "Pressed")
    draw_text( x2 + ui(4 + 8), menu_y + ui(8 + 40 * 0 + 16), "Unpressed")
    draw_text( x2 + ui(4 + 8), menu_y + ui(8 + 40 * 1 + 16), "Pressed")

    tb_btx_value_press.draw(  tb_btx_value_press,   ui(8 + 120), menu_y + ui(8 + 40 * 0), x0 - ui(16 + 120), ui(32), btx_value_press)
    tb_btx_value_unpress.draw(tb_btx_value_unpress, ui(8 + 120), menu_y + ui(8 + 40 * 1), x0 - ui(16 + 120), ui(32), btx_value_unpress)
    
    tb_bty_value_press.draw(  tb_bty_value_press,   x0 + ui(4 + 120), menu_y + ui(8 + 40 * 0), x0 - ui(16 + 120), ui(32), bty_value_press)
    tb_bty_value_unpress.draw(tb_bty_value_unpress, x0 + ui(4 + 120), menu_y + ui(8 + 40 * 1), x0 - ui(16 + 120), ui(32), bty_value_unpress)
    
    tb_bta_value_press.draw(  tb_bta_value_press,   x1 + ui(4 + 120), menu_y + ui(8 + 40 * 0), x0 - ui(16 + 120), ui(32), bta_value_press)
    tb_bta_value_unpress.draw(tb_bta_value_unpress, x1 + ui(4 + 120), menu_y + ui(8 + 40 * 1), x0 - ui(16 + 120), ui(32), bta_value_unpress)
    
    tb_btb_value_press.draw(  tb_btb_value_press,   x2 + ui(4 + 120), menu_y + ui(8 + 40 * 0), x0 - ui(16 + 120), ui(32), btb_value_press)
    tb_btb_value_unpress.draw(tb_btb_value_unpress, x2 + ui(4 + 120), menu_y + ui(8 + 40 * 1), x0 - ui(16 + 120), ui(32), btb_value_unpress)
end

function drawSettings_dpad(menu_y)
    xc = Panel.w / 2;

    draw_set_color(color_icon_dark)
    draw_roundrect_ext(      ui(8), menu_y - ui(20),      xc - ui(4), menu_y + ui(48), ui(4), ui(4), true)
    draw_roundrect_ext( xc + ui(4), menu_y - ui(20), Panel.w - ui(8), menu_y + ui(48), ui(4), ui(4), true)
    
    draw_text_set_format(3)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_text(      ui(8 + 8), menu_y - ui(20) + ui(2), "Horizontal")
    draw_text( xc + ui(4 + 8), menu_y - ui(20) + ui(2), "Vertical")

    draw_set_valign(fa_center)
    draw_text_set_format(1)
    draw_text(      ui(8 + 8), menu_y + ui(8 + 40 * 0 + 16), "Increment")
    draw_text( xc + ui(4 + 8), menu_y + ui(8 + 40 * 0 + 16), "Increment")

    tb_pdh_value.draw(    tb_pdh_value,      ui(8 + 100), menu_y + ui(8 + 40 * 0), xc - ui(16 + 100), ui(32), pdh_value)
    tb_pdv_value.draw(    tb_pdv_value, xc + ui(4 + 100), menu_y + ui(8 + 40 * 0), xc - ui(16 + 100), ui(32), pdv_value)
end

function drawSettings_trigger(menu_y)
    x0 = Panel.w / 4 * 1;
    x1 = Panel.w / 4 * 2;
    x2 = Panel.w / 4 * 3;
    x3 = Panel.w / 4 * 4;

    draw_set_color(color_icon_dark)
    draw_roundrect_ext(      ui(8), menu_y - ui(20), x0 - ui(4), menu_y + ui(88), ui(4), ui(4), true)
    draw_roundrect_ext( x0 + ui(4), menu_y - ui(20), x1 - ui(4), menu_y + ui(88), ui(4), ui(4), true)
    draw_roundrect_ext( x1 + ui(4), menu_y - ui(20), x2 - ui(4), menu_y + ui(88), ui(4), ui(4), true)
    draw_roundrect_ext( x2 + ui(4), menu_y - ui(20), x3 - ui(8), menu_y + ui(88), ui(4), ui(4), true)
    
    draw_text_set_format(3)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_text(      ui(8 + 8), menu_y - ui(20 - 2), "Left trigger")
    draw_text( x0 + ui(4 + 8), menu_y - ui(20 - 2), "Left back trigger")
    draw_text( x1 + ui(4 + 8), menu_y - ui(20 - 2), "Right trigger")
    draw_text( x2 + ui(4 + 8), menu_y - ui(20 - 2), "Right back trigger")

    draw_set_valign(fa_center)
    draw_text_set_format(1)
    draw_text(      ui(8 + 8), menu_y + ui(8 + 40 * 0 + 16), "Unpressed")
    draw_text(      ui(8 + 8), menu_y + ui(8 + 40 * 1 + 16), "Pressed")
    draw_text( x0 + ui(4 + 8), menu_y + ui(8 + 40 * 0 + 16), "Unpressed")
    draw_text( x0 + ui(4 + 8), menu_y + ui(8 + 40 * 1 + 16), "Pressed")
    draw_text( x1 + ui(4 + 8), menu_y + ui(8 + 40 * 0 + 16), "Unpressed")
    draw_text( x1 + ui(4 + 8), menu_y + ui(8 + 40 * 1 + 16), "Pressed")
    draw_text( x2 + ui(4 + 8), menu_y + ui(8 + 40 * 0 + 16), "Unpressed")
    draw_text( x2 + ui(4 + 8), menu_y + ui(8 + 40 * 1 + 16), "Pressed")

    tb_trl_value_press.draw(  tb_trl_value_press,   ui(8 + 120), menu_y + ui(8 + 40 * 0), x0 - ui(16 + 120), ui(32), trl_value_press)
    tb_trl_value_unpress.draw(tb_trl_value_unpress, ui(8 + 120), menu_y + ui(8 + 40 * 1), x0 - ui(16 + 120), ui(32), trl_value_unpress)
    
    tb_trlb_value_press.draw(  tb_trlb_value_press,   x0 + ui(4 + 120), menu_y + ui(8 + 40 * 0), x0 - ui(16 + 120), ui(32), trlb_value_press)
    tb_trlb_value_unpress.draw(tb_trlb_value_unpress, x0 + ui(4 + 120), menu_y + ui(8 + 40 * 1), x0 - ui(16 + 120), ui(32), trlb_value_unpress)
    
    tb_trr_value_press.draw(  tb_trr_value_press,   x1 + ui(4 + 120), menu_y + ui(8 + 40 * 0), x0 - ui(16 + 120), ui(32), trr_value_press)
    tb_trr_value_unpress.draw(tb_trr_value_unpress, x1 + ui(4 + 120), menu_y + ui(8 + 40 * 1), x0 - ui(16 + 120), ui(32), trr_value_unpress)
    
    tb_trrb_value_press.draw(  tb_trrb_value_press,   x2 + ui(4 + 120), menu_y + ui(8 + 40 * 0), x0 - ui(16 + 120), ui(32), trrb_value_press)
    tb_trrb_value_unpress.draw(tb_trrb_value_unpress, x2 + ui(4 + 120), menu_y + ui(8 + 40 * 1), x0 - ui(16 + 120), ui(32), trrb_value_unpress)
end

function drawSettings()
    xc = Panel.w / 2;
    menu_y = ui(320)

    draw_text_set_format(1)
    draw_set_halign(fa_center)
    draw_set_valign(fa_center)
    draw_set_color(color_icon_light)

    menus = {"Analog", "Button", "D-Pad", "Trigger"}
    mn_sx = xc - (4 - 1) / 2 * ui(80)

    for i = 0, 3 do
        mn_x = mn_sx + i * ui(80)
        mn_y = menu_y + 0
        mn_w = string_width(menus[i + 1]) + ui(16)
        mn_h = ui(32)

        if(setting_page == i) then
            draw_sprite_stretched_ext(s_ui_panel_bg, 0, mn_x - mn_w / 2, mn_y - mn_h / 2, mn_w, mn_h, color_icon, 1)
            draw_set_color(color_icon_light)
        else
            if(point_in_rectangle(Panel.mouse[1], Panel.mouse[2], mn_x - mn_w / 2, mn_y - mn_h / 2, mn_x + mn_w / 2, mn_y + mn_h / 2) == 1) then
                draw_sprite_stretched_ext(s_ui_panel_bg, 0, mn_x - mn_w / 2, mn_y - mn_h / 2, mn_w, mn_h, c_white, 1)
                if(mouse_check_button_pressed(mb_left) == 1) then
                    setting_page = i
                end
            end
            draw_set_color(color_icon)
        end

        draw_text(mn_x, mn_y, menus[i + 1])
    end

    _menu_y = menu_y + ui(48)

    if(setting_page == 0) then
        drawSettings_analog(_menu_y)
    elseif(setting_page == 1) then
        drawSettings_button(_menu_y)
    elseif(setting_page == 2) then
        drawSettings_dpad(_menu_y)
    elseif(setting_page == 3) then
        drawSettings_trigger(_menu_y)
    end
end

function drawControl()
    if(record_loop and not animation_playing()) then
        recording = false
        record_loop = false
    end

    bx = Panel.w - ui(8 + 16)
    by = ui(8 + 16)

    if(point_in_rectangle(Panel.mouse[1], Panel.mouse[2], bx - ui(16), by - ui(16), bx + ui(16), by + ui(16)) == 1) then
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, bx - ui(16), by - ui(16), ui(32), ui(32), c_white, 1)
        if recording then 
            set_tooltip("Recording") 
        else 
            set_tooltip("Record")
        end

        if(mouse_check_button_pressed(mb_left) == 1) then
            recording = not recording
        end
    end
    
    c = color_icon_dark
    if recording then c = color_negative end
    draw_sprite_ext(s_animation_control, 2, bx, by, ui(1), ui(1), 0, c, 1)

    bx = bx - ui(32 + 4)

    if(point_in_rectangle(Panel.mouse[1], Panel.mouse[2], bx - ui(16), by - ui(16), bx + ui(16), by + ui(16)) == 1) then
        draw_sprite_stretched_ext(s_ui_panel_bg, 0, bx - ui(16), by - ui(16), ui(32), ui(32), c_white, 1)
        set_tooltip("Play animation once and record")

        if(mouse_check_button_pressed(mb_left) == 1) then
            animation_render()
            recording = true
            record_loop = true
        end
    end

    i = 0
    c = color_positive
    if record_loop then 
        i = 1 
        c = color_icon
    end
    
    draw_sprite_ext(s_animation_control, i, bx, by, ui(1), ui(1), 0, c, 1)
end

function draw()
    -- Use this function to draw the UI element in the panel.
    -- The coordinate in this function is relative to the panel.

    if(setting_page < 3) then
        drawPad()
    else
        drawPadTop()
    end

    drawSettings()
    drawControl()
end

function drawUI()
    -- Use this function to draw the UI element anywhere on the program.
    -- The coordinate in this function is relative to the program window.

    if lana_drag or rana_drag or btx_drag or bty_drag or bta_drag or btb_drag or pdh_drag or pdv_drag or trl_drag or trlb_drag or trr_drag or trrb_drag then
        draw_set_color(color_white)
        draw_line_round(drag_sx, drag_sy, Panel.mouseUI[1], Panel.mouseUI[2], 2)
    else 
        return
    end
    
    if mouse_check_button_released(mb_left) == 0 then
        return
    end

    _key  = element_get("internalName")
    _node = element_get("node", "internalName")

    if lana_drag then
        if(_key ~= nil and _node ~= nil) then
            lana_valueKey = _key
            lana_node = _node
        end

        lana_drag = false
    end

    if rana_drag then
        if(_key ~= nil and _node ~= nil) then
            rana_valueKey = _key
            rana_node = _node
        end

        rana_drag = false
    end

    if btx_drag then
        if(_key ~= nil and _node ~= nil) then
            btx_valueKey = _key
            btx_node = _node
        end

        btx_drag = false
    end

    if bty_drag then
        if(_key ~= nil and _node ~= nil) then
            bty_valueKey = _key
            bty_node = _node
        end

        bty_drag = false
    end

    if bta_drag then
        if(_key ~= nil and _node ~= nil) then
            bta_valueKey = _key
            bta_node = _node
        end

        bta_drag = false
    end

    if btb_drag then
        if(_key ~= nil and _node ~= nil) then
            btb_valueKey = _key
            btb_node = _node
        end

        btb_drag = false
    end

    if pdh_drag then
        if(_key ~= nil and _node ~= nil) then
            pdh_valueKey = _key
            pdh_node = _node
        end

        pdh_drag = false
    end

    if pdv_drag then
        if(_key ~= nil and _node ~= nil) then
            pdv_valueKey = _key
            pdv_node = _node
        end

        pdv_drag = false
    end

    if trl_drag then
        if(_key ~= nil and _node ~= nil) then
            trl_valueKey = _key
            trl_node = _node
        end

        trl_drag = false
    end

    if trlb_drag then
        if(_key ~= nil and _node ~= nil) then
            trlb_valueKey = _key
            trlb_node = _node
        end

        trlb_drag = false
    end

    if trr_drag then
        if(_key ~= nil and _node ~= nil) then
            trr_valueKey = _key
            trr_node = _node
        end

        trr_drag = false
    end

    if trrb_drag then
        if(_key ~= nil and _node ~= nil) then
            trrb_valueKey = _key
            trrb_node = _node
        end

        trrb_drag = false
    end
end

function closePanel()
    node = ""
    valueKey = ""
end
