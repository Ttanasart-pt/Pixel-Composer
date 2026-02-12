---@diagnostic disable: lowercase-global

lana_node = "";  lana_valueKey = "";  lana_center = { 0, 0 };  lana_scale  = 1; lana_drag = false;
rana_node = "";  rana_valueKey = "";  rana_center = { 0, 0 };  rana_scale  = 1; rana_drag = false;

btx_node = "";  btx_valueKey = "";  btx_value_press = 1;  btx_value_unpress = 0;  btx_drag = false;
bty_node = "";  bty_valueKey = "";  bty_value_press = 1;  bty_value_unpress = 0;  bty_drag = false;
bta_node = "";  bta_valueKey = "";  bta_value_press = 1;  bta_value_unpress = 0;  bta_drag = false;
btb_node = "";  btb_valueKey = "";  btb_value_press = 1;  btb_value_unpress = 0;  btb_drag = false;

pdh_node = "";  pdh_valueKey = "";  pdh_value = { -1, 1 };  pdh_drag = false;
pdv_node = "";  pdv_valueKey = "";  pdv_value = { -1, 1 };  pdv_drag = false;

trl_node  = "";  trl_valueKey  = "";  trl_value_press  = 1;  trl_value_unpress  = 0;  trl_drag  = false;
trlb_node = "";  trlb_valueKey = "";  trlb_value_press = 1;  trlb_value_unpress = 0;  trlb_drag = false;
trr_node  = "";  trr_valueKey  = "";  trr_value_press  = 1;  trr_value_unpress  = 0;  trr_drag  = false;
trrb_node = "";  trrb_valueKey = "";  trrb_value_press = 1;  trrb_value_unpress = 0;  trrb_drag = false;

drag_sx = 0
drag_sy = 0

deadZone = 0
recording = true
record_loop = false

setting_page = 0;

function onEdit_lana_Center(i, cen) lana_center[i] = cen;   return true; end
function onEdit_lana_Scale(sca)     lana_scale = sca;       return true; end
function onEdit_rana_Center(i, cen) rana_center[i] = cen;   return true; end
function onEdit_rana_Scale(sca)     rana_scale = sca;       return true; end

function onEdit_btx_value_press(val)   btx_value_press = val;     return true; end
function onEdit_bty_value_press(val)   bty_value_press = val;     return true; end
function onEdit_bta_value_press(val)   bta_value_press = val;     return true; end
function onEdit_btb_value_press(val)   btb_value_press = val;     return true; end

function onEdit_btx_value_unpress(val)   btx_value_unpress = val;     return true; end
function onEdit_bty_value_unpress(val)   bty_value_unpress = val;     return true; end
function onEdit_bta_value_unpress(val)   bta_value_unpress = val;     return true; end
function onEdit_btb_value_unpress(val)   btb_value_unpress = val;     return true; end

function onEdit_pdh_value(i, val)   pdh_value[i] = val;     return true; end
function onEdit_pdv_value(i, val)   pdv_value[i] = val;     return true; end

function onEdit_trl_value_press(val)   trl_value_press = val;     return true; end
function onEdit_trlb_value_press(val)  trlb_value_press = val;    return true; end
function onEdit_trr_value_press(val)   trr_value_press = val;     return true; end
function onEdit_trrb_value_press(val)  trrb_value_press = val;    return true; end

function onEdit_trl_value_unpress(val)   trl_value_unpress = val;     return true; end
function onEdit_trlb_value_unpress(val)  trlb_value_unpress = val;    return true; end
function onEdit_trr_value_unpress(val)   trr_value_unpress = val;     return true; end
function onEdit_trrb_value_unpress(val)  trrb_value_unpress = val;    return true; end

function onEdit_Deadzone(ded)
    gamepad_set_axis_deadzone(0, ded)
    deadZone = ded
    return true
end
onEdit_Deadzone(0.1)

function init()
    -- This function runs once the add-on is activated.
    s_controller           = sprite_add("./img/controller outline.png",   2, false, false, 240,  0)
    s_controller_knob      = sprite_add("./img/controller knob.png",      2, false, false,  16, 16)
    s_controller_arrow     = sprite_add("./img/controller arrow.png",     4, false, false,  32, 32)
    s_controller_button    = sprite_add("./img/controller button.png",    4, false, false,  16, 16)
    s_controller_trigger   = sprite_add("./img/controller trigger.png",   2, false, false, 100, 40)
    s_controller_dpad_axis = sprite_add("./img/controller dpad axis.png", 2, false, false,  16, 16)
    s_animation_control    = sprite_add("./img/animation control.png",    3, false, false,  12, 12)

    tb_lana_Center = VectorBox.new(2, "onEdit_lana_Center")
    tb_lana_Scale  = TextBox.new(tb_number, "onEdit_lana_Scale")
    tb_rana_Center = VectorBox.new(2, "onEdit_rana_Center")
    tb_rana_Scale  = TextBox.new(tb_number, "onEdit_rana_Scale")
    tbDead         = TextBox.new(tb_number, "onEdit_Deadzone")

    tb_btx_value_press   = TextBox.new(tb_number, "onEdit_btx_value_press")
    tb_bty_value_press   = TextBox.new(tb_number, "onEdit_bty_value_press")
    tb_bta_value_press   = TextBox.new(tb_number, "onEdit_bta_value_press")
    tb_btb_value_press   = TextBox.new(tb_number, "onEdit_btb_value_press")
    
    tb_btx_value_unpress   = TextBox.new(tb_number, "onEdit_btx_value_unpress")
    tb_bty_value_unpress   = TextBox.new(tb_number, "onEdit_bty_value_unpress")
    tb_bta_value_unpress   = TextBox.new(tb_number, "onEdit_bta_value_unpress")
    tb_btb_value_unpress   = TextBox.new(tb_number, "onEdit_btb_value_unpress")

    tb_pdh_value   = VectorBox.new(2, "onEdit_pdh_value")
    tb_pdv_value   = VectorBox.new(2, "onEdit_pdv_value")

    tb_trl_value_press   = TextBox.new(tb_number, "onEdit_trl_value_press")
    tb_trlb_value_press  = TextBox.new(tb_number, "onEdit_trlb_value_press")
    tb_trr_value_press   = TextBox.new(tb_number, "onEdit_trr_value_press")
    tb_trrb_value_press  = TextBox.new(tb_number, "onEdit_trrb_value_press")
    
    tb_trl_value_unpress   = TextBox.new(tb_number, "onEdit_trl_value_unpress")
    tb_trlb_value_unpress  = TextBox.new(tb_number, "onEdit_trlb_value_unpress")
    tb_trr_value_unpress   = TextBox.new(tb_number, "onEdit_trr_value_unpress")
    tb_trrb_value_unpress  = TextBox.new(tb_number, "onEdit_trrb_value_unpress")
end

function step()
    -- This function runs every program step.

    if(lana_node ~= "" and lana_valueKey ~= "") then
        haxis = gamepad_axis_value(0, gp_axislh);
        vaxis = gamepad_axis_value(0, gp_axislv);

        val = { lana_center[1] + haxis * lana_scale, lana_center[2] + vaxis * lana_scale }
        node_set_input_value(lana_node, lana_valueKey, val)
    end

    if(rana_node ~= "" and rana_valueKey ~= "") then
        haxis = gamepad_axis_value(0, gp_axisrh);
        vaxis = gamepad_axis_value(0, gp_axisrv);

        val = { rana_center[1] + haxis * rana_scale, rana_center[2] + vaxis * rana_scale }
        node_set_input_value(rana_node, rana_valueKey, val)
    end

    if(btx_node ~= "" and btx_valueKey ~= "") then
        val = gamepad_button_value(0, gp_face3);
        if(val == 1) then node_set_input_value(btx_node, btx_valueKey, btx_value_press)
        else              node_set_input_value(btx_node, btx_valueKey, btx_value_unpress)
        end
    end

    if(bty_node ~= "" and bty_valueKey ~= "") then
        val = gamepad_button_value(0, gp_face4);
        if(val == 1) then node_set_input_value(bty_node, bty_valueKey, bty_value_press)
        else              node_set_input_value(bty_node, bty_valueKey, bty_value_unpress)
        end
    end

    if(bta_node ~= "" and bta_valueKey ~= "") then
        val = gamepad_button_value(0, gp_face1);
        if(val == 1) then node_set_input_value(bta_node, bta_valueKey, bta_value_press)
        else              node_set_input_value(bta_node, bta_valueKey, bta_value_unpress)
        end
    end

    if(btb_node ~= "" and btb_valueKey ~= "") then
        val = gamepad_button_value(0, gp_face2);
        if(val == 1) then node_set_input_value(btb_node, btb_valueKey, btb_value_press)
        else              node_set_input_value(btb_node, btb_valueKey, btb_value_unpress)
        end
    end
    
    if(pdh_node ~= "" and pdh_valueKey ~= "") then
        if(gamepad_button_value(0, gp_padl) == 1) then 
            val = node_get_input_value(pdh_node, pdh_valueKey)
            node_set_input_value(pdh_node, pdh_valueKey, val + pdh_value[1])
        end

        if(gamepad_button_value(0, gp_padr) == 1) then 
            val = node_get_input_value(pdh_node, pdh_valueKey)
            node_set_input_value(pdh_node, pdh_valueKey, val + pdh_value[2])
        end
    end
    
    if(pdv_node ~= "" and pdv_valueKey ~= "") then
        if(gamepad_button_value(0, gp_padd) == 1) then 
            val = node_get_input_value(pdv_node, pdv_valueKey)
            node_set_input_value(pdv_node, pdv_valueKey, val + pdv_value[1])
        end

        if(gamepad_button_value(0, gp_padu) == 1) then 
            val = node_get_input_value(pdv_node, pdv_valueKey)
            node_set_input_value(pdv_node, pdv_valueKey, val + pdv_value[2])
        end
    end

    if(trl_node ~= "" and trl_valueKey ~= "") then
        val = gamepad_button_value(0, gp_shoulderl);
        if(val == 1) then node_set_input_value(trl_node, trl_valueKey, trl_value_press)
        else              node_set_input_value(trl_node, trl_valueKey, trl_value_unpress)
        end
    end

    if(trlb_node ~= "" and trlb_valueKey ~= "") then
        val = gamepad_button_value(0, gp_shoulderlb);
        node_set_input_value(trlb_node, trlb_valueKey, lerp(trlb_value_unpress, trlb_value_press, 1 - val))
    end

    if(trr_node ~= "" and trr_valueKey ~= "") then
        val = gamepad_button_value(0, gp_shoulderr);
        if(val == 1) then node_set_input_value(trr_node, trr_valueKey, trr_value_press)
        else              node_set_input_value(trr_node, trr_valueKey, trr_value_unpress)
        end
    end

    if(trrb_node ~= "" and trrb_valueKey ~= "") then
        val = gamepad_button_value(0, gp_shoulderrb);
        node_set_input_value(trrb_node, trrb_valueKey, lerp(trrb_value_unpress, trrb_value_press, 1 - val))
    end

end

function animationPreStep()
    -- This function runs every animation frame before node execution
end

function animationPostStep()
    -- This function runs every animation frame after node execution
end

function destroy()
    -- This function is call when the addon is destroyed (close dialog, close program)
end

function setValue_lana(_data)
    lana_valueKey = _data.internalName
    lana_node = _data.node.internalName

    panel_create("panel_controller")
end

function setValue_rana(_data)
    rana_valueKey = _data.internalName
    rana_node = _data.node.internalName

    panel_create("panel_controller")
end

function setValue_btx(_data)
    btx_valueKey = _data.internalName
    btx_node = _data.node.internalName

    panel_create("panel_controller")
end

function setValue_bty(_data)
    bty_valueKey = _data.internalName
    bty_node = _data.node.internalName

    panel_create("panel_controller")
end

function setValue_bta(_data)
    bta_valueKey = _data.internalName
    bta_node = _data.node.internalName

    panel_create("panel_controller")
end

function setValue_btb(_data)
    btb_valueKey = _data.internalName
    btb_node = _data.node.internalName

    panel_create("panel_controller")
end

function setValue_pdh(_data)
    pdh_valueKey = _data.internalName
    pdh_node = _data.node.internalName

    panel_create("panel_controller")
end

function setValue_pdv(_data)
    pdv_valueKey = _data.internalName
    pdv_node = _data.node.internalName

    panel_create("panel_controller")
end

function setValue_trl(_data)
    trl_valueKey = _data.internalName
    trl_node = _data.node.internalName

    panel_create("panel_controller")
end

function setValue_trlb(_data)
    trlb_valueKey = _data.internalName
    trlb_node = _data.node.internalName

    panel_create("panel_controller")
end

function setValue_trr(_data)
    trr_valueKey = _data.internalName
    trr_node = _data.node.internalName

    panel_create("panel_controller")
end

function setValue_trrb(_data)
    trrb_valueKey = _data.internalName
    trrb_node = _data.node.internalName

    panel_create("panel_controller")
end

function node_value_inspector_callback()
    return {
        { name = "Map to controller", content = {
            { name = "Left analog stick", callback = "setValue_lana" },
            { name = "Right analog stick", callback = "setValue_rana" },
            -1, 
            { name = "X button", callback = "setValue_btx" },
            { name = "Y button", callback = "setValue_bty" },
            { name = "A button", callback = "setValue_bta" },
            { name = "B button", callback = "setValue_btb" },
            -1, 
            { name = "Horizontal D pad", callback = "setValue_pdh" },
            { name = "Vertical D pad", callback = "setValue_pdv" },
            -1,
            { name = "Left trigger", callback = "setValue_trl" },
            { name = "Left back trigger", callback = "setValue_trlb" },
            { name = "Right trigger", callback = "setValue_trr" },
            { name = "Right back trigger", callback = "setValue_trrb" },
        }}
    }
end

function serialize()
    -- This function is call when the project is saved.
    -- The value is append to the project file.

    return {
        lana_node = lana_node,  lana_valueKey = lana_valueKey,  lana_center = lana_center,  lana_scale  = lana_scale,
        rana_node = rana_node,  rana_valueKey = rana_valueKey,  rana_center = rana_center,  rana_scale  = rana_scale,

        btx_node = btx_node,  btx_valueKey = btx_valueKey,  btx_value_press = btx_value_press,  btx_value_unpress = btx_value_unpress, 
        bty_node = bty_node,  bty_valueKey = bty_valueKey,  bty_value_press = bty_value_press,  bty_value_unpress = bty_value_unpress, 
        bta_node = bta_node,  bta_valueKey = bta_valueKey,  bta_value_press = bta_value_press,  bta_value_unpress = bta_value_unpress, 
        btb_node = btb_node,  btb_valueKey = btb_valueKey,  btb_value_press = btb_value_press,  btb_value_unpress = btb_value_unpress, 

        pdh_node = pdh_node,  pdh_valueKey = pdh_valueKey,  pdh_value = pdh_value, 
        pdv_node = pdv_node,  pdv_valueKey = pdv_valueKey,  pdv_value = pdv_value, 

        trl_node  = trl_node,   trl_valueKey  = trl_valueKey,   trl_value_press  = trl_value_press,   trl_value_unpress  = trl_value_unpress, 
        trlb_node = trlb_node,  trlb_valueKey = trlb_valueKey,  trlb_value_press = trlb_value_press,  trlb_value_unpress = trlb_value_unpress, 
        trr_node  = trr_node,   trr_valueKey  = trr_valueKey,   trr_value_press  = trr_value_press,   trr_value_unpress  = trr_value_unpress, 
        trrb_node = trrb_node,  trrb_valueKey = trrb_valueKey,  trrb_value_press = trrb_value_press,  trrb_value_unpress = trrb_value_unpress, 
    }
end

function deserialize(_data)
    -- This function is call when the project is loaded.
    -- 

    lana_node = _data.lana_node;  lana_valueKey = _data.lana_valueKey;  lana_center = _data.lana_center;            lana_scale  = _data.lana_scale;
    rana_node = _data.rana_node;  rana_valueKey = _data.rana_valueKey;  rana_center = _data.rana_center;            rana_scale  = _data.rana_scale;

    btx_node = _data.btx_node;    btx_valueKey = _data.btx_valueKey;    btx_value_press = _data.btx_value_press;    btx_value_unpress = _data.btx_value_unpress;
    bty_node = _data.bty_node;    bty_valueKey = _data.bty_valueKey;    bty_value_press = _data.bty_value_press;    bty_value_unpress = _data.bty_value_unpress;
    bta_node = _data.bta_node;    bta_valueKey = _data.bta_valueKey;    bta_value_press = _data.bta_value_press;    bta_value_unpress = _data.bta_value_unpress;
    btb_node = _data.btb_node;    btb_valueKey = _data.btb_valueKey;    btb_value_press = _data.btb_value_press;    btb_value_unpress = _data.btb_value_unpress;

    pdh_node = _data.pdh_node;    pdh_valueKey = _data.pdh_valueKey;    pdh_value = _data.pdh_value;
    pdv_node = _data.pdv_node;    pdv_valueKey = _data.pdv_valueKey;    pdv_value = _data.pdv_value;
    
    trl_node  = _data.trl_node;   trl_valueKey  = _data.trl_valueKey;   trl_value_press  = _data.trl_value_press;   trl_value_unpress  = _data.trl_value_unpress;
    trlb_node = _data.trlb_node;  trlb_valueKey = _data.trlb_valueKey;  trlb_value_press = _data.trlb_value_press;  trlb_value_unpress = _data.trlb_value_unpress;
    trr_node  = _data.trr_node;   trr_valueKey  = _data.trr_valueKey;   trr_value_press  = _data.trr_value_press;   trr_value_unpress  = _data.trr_value_unpress;
    trrb_node = _data.trrb_node;  trrb_valueKey = _data.trrb_valueKey;  trrb_value_press = _data.trrb_value_press;  trrb_value_unpress = _data.trrb_value_unpress;
end