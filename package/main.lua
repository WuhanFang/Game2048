LXZDoFile("LXZHelper.lua");
LXZDoFile("serial.lua");

--��¼�����ļ�
local cfg = ILXZCoreCfg:new_local();
cfg:load(LXZAPIGetWritePath().."game_info.cfg");

local function create_number(name,number)
	local root = HelperGetRoot();
	local grids = root:GetLXZWindow("game:back grids")
	local main = root:GetLXZWindow("game:main");
	local dictions = root:GetLXZWindow("dictions")
		
	local pt = grids:GetChild(name):GetHotPos(true); --��ȡ����������
	local w=dictions:GetChild("number "..number):Clone();--���ֵ��п�¡���ִ���
	w:SetName(name);                                                   --���ָĳɺͱ�����һ��
	main:AddChild(w);                                                             --���������������
	w:SetHotPos(pt,true);			                                              --λ�úͱ����񱣳�һ��
	w:SetAddData(number);                                                   --ָ��������		
	AddWndUpdateFunc(w, EffectEase,{type=tween.CIRC, fn=tween.easeOut, begin=0, offset=-0.5, change=0.5, duration=500,reset=true,attribute="CLXZWindow:Scale:fScaleX"},nil, 1);
	AddWndUpdateFunc(w, EffectEase,{type=tween.CIRC, fn=tween.easeOut, begin=0, offset=-0.5, change=0.5, duration=500,reset=true,attribute="CLXZWindow:Scale:fScaleY"},nil, 2);		
end

--�����2��4
 local function random_number()
		local root = HelperGetRoot();
		local grids = root:GetLXZWindow("game:back grids")
		local main = root:GetLXZWindow("game:main");
		local dictions = root:GetLXZWindow("dictions")
		
		--��ȡ��λ��
        local tiles = {};
		for col=1,4,1 do
			for row=1,4,1 do
				local number=main:GetChild(col.."x"..row);				
				if number == nil then
					table.insert(tiles, col.."x"..row);
				end
			end
		end
		
		--���һ����λ
		local index = math.random(1,table.getn(tiles));
		if tiles[index]==nil then
			return;
		end
		
		--80%�ĸ��ʳ�2, 20%�ĸ��ʳ�4
		local number = 2;
		local random = math.random(1,100);
		if random>80 then
			number=4;
		end
		
		--test
		
		--��¡һ�����ִ���,�ӵ�����У�λ�úͱ������ص�
		create_number(tiles[index],number);
end

--��Ϸ��ʼ��ʼ���������������
 local function game_init()
	--���
 	local root = HelperGetRoot();
	local main = root:GetLXZWindow("game:main");
	main:ClearChilds();
	
	--
	root:GetLXZWindow("start"):Hide();
	root:GetLXZWindow("game over"):Hide();
	
	
	--�������
    random_number();
	 random_number();
	 --[[create_number("1x1",2);
	 create_number("2x1",2);
	 create_number("3x1",2);
	 create_number("4x1",2);--]]
	 
	 local bonus_w = root:GetLXZWindow("head:bonus:number");
	HelperSetWindowText(bonus_w, tostring(0));
	HelperSetWindowText(root:GetLXZWindow("game over:bonus:bonus"), tostring(0));
	
	local maxcore=cfg:GetInt("maxcore");
	HelperSetWindowText(root:GetLXZWindow("head:history:number"), tostring(maxcore));
		
	
 end
	

local function merge(dst_col, dst_row, src_col, src_row)
		local root   = HelperGetRoot();		
		local main = root:GetLXZWindow("game:main");
		local grids = root:GetLXZWindow("game:back grids")
		local dictions = root:GetLXZWindow("dictions")
		
		local src = main:GetChild(src_col.."x"..src_row);
		if src==nil then
			return false;
		end
		
		local dst = main:GetChild(dst_col.."x"..dst_row);
		if dst == nil then --Ŀ��λ��Ϊ��
			local pt = grids:GetChild(dst_col.."x"..dst_row):GetHotPos(true);
			src:SetName(dst_col.."x"..dst_row); --reset name.
			src:SetHotPos(pt, true); --reset position
			return false;
		end
		
		--���ֲ�ͬ
		if src:GetAddData() ~= dst:GetAddData() then
			return false;
		end
		
		--��ͬ�����򷭱�,		
		local number = src:GetAddData()*2;
		src:Delete(); --ɾ��ԭ����
		dst:Delete(); --ɾ��Ŀ������
		
		--��¡������
		local clone = dictions:GetChild("number "..number):Clone();
		main:AddChild(clone);
		
		--����Ŀ�����λ��
		local pt = grids:GetChild(dst_col.."x"..dst_row):GetHotPos(true); --���λ��
		clone:SetName(dst_col.."x"..dst_row); --reset name.
		clone:SetHotPos(pt, true); --reset position
		clone:SetAddData(number); --set number		
		AddWndUpdateFunc(clone, EffectEase,{type=tween.CIRC, fn=tween.easeOut, begin=0, offset=-0.5, change=0.5, duration=500,reset=true,attribute="CLXZWindow:Scale:fScaleX"},nil, 1);
		AddWndUpdateFunc(clone, EffectEase,{type=tween.CIRC, fn=tween.easeOut, begin=0, offset=-0.5, change=0.5, duration=500,reset=true,attribute="CLXZWindow:Scale:fScaleY"},nil, 2);
		AddWndUpdateFunc(clone, EffectEase,{type=tween.CIRC, fn=tween.easeOut, begin=0, offset=-200, change=200, duration=500,reset=true,attribute="CLXZWindow:Mask:alpha"},nil, 3);
		
		--����
		local bonus_w = root:GetLXZWindow("head:bonus:number");
		local bonus = tonumber(HelperGetWindowText(bonus_w));
		bonus = bonus+number;
		HelperSetWindowText(bonus_w, tostring(bonus));
		HelperSetWindowText(root:GetLXZWindow("game over:bonus:bonus"), tostring(bonus));
		
		local maxcore=cfg:GetInt("maxcore");
		if bonus>maxcore then
			cfg:SetInt("maxcore", -1, bonus);
		end
		
		return true;
end

local function tighten_move_line(v,direction)
	local root = HelperGetRoot();
	local main = root:GetLXZWindow("game:main");
	local grids = root:GetLXZWindow("game:back grids")
	
	local count=0;
	if direction=="left" then
		for col=1,4,1 do
			local w = main:GetChild(col.."x"..v);
			if w then
				count=count+1;				
				local pt = grids:GetChild(count.."x"..v):GetHotPos(true);
				w:SetName(count.."x"..v); --reset name.
				w:SetHotPos(pt, true); --reset position
			end
		end
	elseif direction=="right" then
		for col=4,1,-1 do
			local w = main:GetChild(col.."x"..v);
			if w then						
				local pt = grids:GetChild((4-count).."x"..v):GetHotPos(true);
				w:SetName((4-count).."x"..v); --reset name.
				w:SetHotPos(pt, true); --reset position
				count=count+1;		
			end
		end
	elseif direction=="top" then
		for row=1,4,1 do
			local w = main:GetChild(v.."x"..row);
			if w then
				count=count+1;				
				local pt = grids:GetChild(v.."x"..count):GetHotPos(true);
				w:SetName(v.."x"..count); --reset name.
				w:SetHotPos(pt, true); --reset position
			end
		end
	elseif direction=="bottom" then
		for row=4,1,-1 do
			local w = main:GetChild(v.."x"..row);
			if w then						
				local pt = grids:GetChild(v.."x"..(4-count)):GetHotPos(true);
				w:SetName(v.."x"..(4-count)); --reset name.
				w:SetHotPos(pt, true); --reset position
				count=count+1;		
			end
		end
	end	
end

--�����ں�	
local function move(direction)
	LXZAPI_OutputDebugStr("move:"..direction);
	
	if direction=="top" then
		for col=1,4,1 do
			tighten_move_line(col, direction);
			for row=1,4,1 do				
				if merge(col, row, col, row+1) then 
					tighten_move_line(col, direction);
				end
			end
		end	
	elseif direction=="bottom" then
		for col=1,4,1 do
			tighten_move_line(col, direction);
			for row=4,1,-1 do				
				if merge(col, row, col, row-1) then
					tighten_move_line(col, direction);
				end
			end
			--tighten_move_line(col, direction);
		end	
	elseif direction=="left" then
		for row=1,4,1 do
			tighten_move_line(row, direction);
			for col=1,4,1 do				
				if merge(col, row, col+1, row) then
					tighten_move_line(row, direction);
				end
			end
			--tighten_move_line(row, direction);
		end	
	elseif direction=="right" then
		for row=1,4,1 do
			tighten_move_line(row, direction);
			for col=4,1,-1 do				
				if merge(col, row, col-1, row) then
					tighten_move_line(row, direction);
				end
			end
			--tighten_move_line(row, direction);
		end	
	end
       
	 random_number();
end

--�Ƿ���ͬ
local function is_equal(dst_col, dst_row, src_col, src_row)
	local root   = HelperGetRoot();		
	local main = root:GetLXZWindow("game:main");
	
	local src = main:GetChild(src_col.."x"..src_row);
	if src==nil then
		return false;
	end
		
	local dst = main:GetChild(dst_col.."x"..dst_row);
	if dst == nil then --Ŀ��λ��Ϊ��
		return false;
	end
		
		--���ֲ�ͬ
	if src:GetAddData() ~= dst:GetAddData() then
		return false;
	end
	
	return true;	
end

--�Ƿ����
local function is_game_over()
	local root   = HelperGetRoot();		
	local main = root:GetLXZWindow("game:main");
	for col=1,4,1 do
		for row=1,4,1 do
			--����пո���δ������
			local w = main:GetChild(col.."x"..row);
			if w== nil then
				return false;
			end
			
			--�������ֵ,�����
			if w:GetAddData()==2048 then
				return true;
			end
			
			--���������ֵͬ����δ������
			if is_equal(col,row,col,row+1) then
				return false;
			end
						
			if is_equal(col,row,col+1,row) then
				return false;
			end			
		end
	end	
	
	return true;
end

local function OnStart(window, msg, sender)
	game_init();
end

local function OnUpdate(window, msg, sender)
	UpdateWindow();
	--LXZAPI_OutputDebugStr("OnUpdate")
end

IsLClickDown= false;
local function OnMainClickDown(window, msg, sender)
	IsLClickDown=true;
end

local function OnMainMouseMove(window, msg, sender)
	local corecfg = ICGuiGetLXZCoreCfg();
	if IsLClickDown==false then
		return;
	end
	
	local x = msg:int ();
	local y = msg:int ();
	
	local origin_x = corecfg.nClickDownX;
	local origin_y = corecfg.nClickDownY;
	
	--����ƫ����
	local delta_x=x-origin_x;
	local delta_y=y-origin_y;	
	
	--ʶ�𻬶�����
	if math.abs(delta_x)>math.abs(delta_y) then
		if math.abs(delta_x)>=8 then
			if delta_x<0 then
				move("left");
				IsLClickDown= false;
			else
				move("right");
				IsLClickDown= false;
			end
		end	
	else
		if math.abs(delta_y)>=8 then
			if delta_y<0 then
				move("top");
				IsLClickDown= false;
			else
				move("bottom");
				IsLClickDown= false;
			end
		end	
	end	
	
	if is_game_over() then
		local root = HelperGetRoot();
		root:GetLXZWindow("game over"):Show();
		if cfg then
			cfg:save(LXZAPIGetWritePath().."game_info.cfg");
		end
	end
	
end

--������ɴ����¼�
local function OnLoad(window, msg, sender)
	local root=HelperGetRoot();
	root:GetLXZWindow("game over"):Hide();
	root:GetLXZWindow("start"):Show();		
	
	local maxcore=cfg:GetInt("maxcore");
	HelperSetWindowText(root:GetLXZWindow("head:history:number"), tostring(maxcore));
end

--�¼���
local event_callback = {}
event_callback ["OnStart"] = OnStart;
event_callback ["OnLoad"] = OnLoad;
event_callback ["OnUpdate"] = OnUpdate;
event_callback ["OnMainMouseMove"] = OnMainMouseMove;
event_callback ["OnMainClickDown"] = OnMainClickDown;

--��Ϣ�ɷ��ӿ�
function main_dispacher(window, cmd, msg, sender)
---	LXZAPI_OutputDebugStr("cmd 1:"..cmd);
	if(event_callback[cmd] ~= nil) then
--		LXZAPI_OutputDebugStr("cmd 2:"..cmd);
		event_callback[cmd](window, msg, sender);
	end
end

