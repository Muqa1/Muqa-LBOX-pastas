


local camera_x_position = 5; -- edit these value to your liking
local camera_y_position = 300;
local camera_width = 499;
local camera_height = 300;
local camera_render_scale = 2;



----------------------------------


camera_render_scale = math.max(camera_render_scale, 0.1);

local g_iCameraRenderWidth = math.floor(camera_width * camera_render_scale);
local g_iCameraRenderHeight = math.floor(camera_height * camera_render_scale);
camera_width  = g_iCameraRenderWidth  / camera_render_scale;
camera_height = g_iCameraRenderHeight / camera_render_scale;



local g_aProjectiles = {};

local INDEX_INVALID = -1;

local g_stCamera = {
    m_bActive = false;
    
    m_vecPosition = Vector3(0, 0, 0);
    m_angAngles = EulerAngles(0, 0, 0);
    m_bOverrideAngles = false;

    m_iLastIndex = INDEX_INVALID;

    m_pTexture = materials.CreateTextureRenderTarget("LaunchedProjectileCamera", g_iCameraRenderWidth, g_iCameraRenderHeight );
    m_pMaterial = materials.Create( "LaunchedProjectileCamera", [[UnlitGeneric {$basetexture "LaunchedProjectileCamera"}]]);
};

callbacks.Register("CreateMove", "ProjCamProj", function(cmd)
    local pLocalPlayer = entities.GetLocalPlayer();
    if not pLocalPlayer then 
        g_stCamera.m_bActive = false;
        g_stCamera.m_iLastIndex = INDEX_INVALID;
        return; 
    end

    -- Get all of our stickies and put them in this local table
    local laProjectiles = {};
    for _, pEnt in pairs(entities.FindByClass("CTFGrenadePipebombProjectile")) do
        local iIndex = pEnt:GetIndex();
        local pThrower = pEnt:GetPropEntity("m_hThrower");

        if pThrower and pThrower == pLocalPlayer and pEnt:GetPropInt("m_iType") == 1 then
            laProjectiles[#laProjectiles + 1] = iIndex;
        end
    end

    -- If we havent found any stickies then we clear the global table and disable the camera
    if #laProjectiles == 0 then
        g_aProjectiles = {};
        g_stCamera.m_bActive = false;
        g_stCamera.m_iLastIndex = INDEX_INVALID;

        return;
    end

    -- Add new stickies to the end of our global table
    for _, lidx in pairs(laProjectiles) do
        for _, idx in pairs(g_aProjectiles) do
            if lidx == idx then
                goto continue;
            end
        end

        g_aProjectiles[#g_aProjectiles + 1] = lidx;

        ::continue::
    end

    -- Clear the local stickies table and add valid stickies back to the local table in the same relative order
    laProjectiles = {};
    for idx = 1, #g_aProjectiles do
        if entities.GetByIndex(g_aProjectiles[idx]) then
            laProjectiles[#laProjectiles + 1] = g_aProjectiles[idx];
        end
    end

    -- Set the global table to the local table and make sure we have active stickies
    g_aProjectiles = laProjectiles;
    g_stCamera.m_bActive = (#g_aProjectiles ~= 0);
    if not g_stCamera.m_bActive then
        g_stCamera.m_iLastIndex = INDEX_INVALID;
        return;
    end

    -- Get the latest NON-DORMANT entity ;3
    local pEnt = nil;
    for i = #g_aProjectiles, 1, -1 do
        local lpEnt = entities.GetByIndex(g_aProjectiles[i]);
        if not lpEnt:IsDormant() then
            pEnt = lpEnt;
            break;
        end
    end

    if not pEnt then
        g_stCamera.m_bActive = false;
        g_stCamera.m_iLastIndex = INDEX_INVALID;
        return;
    end

    -- Set the camera data using the current sticky making sure to check if it isnt moving so we dont have a useless camera
    local vecVelocity = pEnt:EstimateAbsVelocity();

    g_stCamera.m_vecPosition = pEnt:GetAbsOrigin() + Vector3(0, 0, 5);
    g_stCamera.m_bOverrideAngles = (vecVelocity:Length() > 0);

    if not g_stCamera.m_bOverrideAngles then
        return;
    end

    -- If we have a new sticky then we dont lerp from the last camera angles, we use the new ones
    local ang = vecVelocity:Angles();
    if g_stCamera.m_iLastIndex ~= g_aProjectiles[#g_aProjectiles] then
        g_stCamera.m_iLastIndex = g_aProjectiles[#g_aProjectiles];
        g_stCamera.m_angAngles = EulerAngles(ang:Unpack());
        return;
    end
        
    -- Lerp between current and goal camera angles to reduce camera jitter
    local dx = ang.x - g_stCamera.m_angAngles.x;
    local dy = ang.y - g_stCamera.m_angAngles.y;

    if dx > 180 then
        ang.x = ang.x - 360;

    elseif dx < -180 then
        ang.x = ang.x + 360;
    end

    if dy > 180 then
        ang.y = ang.y - 360;

    elseif dy < -180 then
        ang.y = ang.y + 360;
    end
    
    g_stCamera.m_angAngles.x = g_stCamera.m_angAngles.x + (ang.x - g_stCamera.m_angAngles.x) * 0.1;
    g_stCamera.m_angAngles.y = g_stCamera.m_angAngles.y + (ang.y - g_stCamera.m_angAngles.y) * 0.1;
end)


callbacks.Register("PostRenderView", function(view)
    if not g_stCamera.m_bActive then
        return;
    end

    -- using (customView = view) just makes customView a reference to view, ive told BF abt this error in the example but they wont fix it...
    -- use this instead... please
    local stView = client.GetPlayerView();
    if g_stCamera.m_bOverrideAngles then
        stView.angles = g_stCamera.m_angAngles;
    end

    -- Set the camera to be offset by 75 units backwards from the object's origin using whatever angles we are using to render with
    stView.origin = g_stCamera.m_vecPosition - (Vector3(stView.angles.x, stView.angles.y, 0):Forward() * 75);
    
    render.Push3DView( stView, E_ClearFlags.VIEW_CLEAR_COLOR | E_ClearFlags.VIEW_CLEAR_DEPTH, g_stCamera.m_pTexture );
    render.ViewDrawScene( true, true, stView );
    render.PopView();
end)

local font = draw.CreateFont( "Tahoma", 12, 800, FONTFLAG_OUTLINE )
callbacks.Register( "Draw", function() 
    local pLocalPlayer = entities.GetLocalPlayer();
    if (not g_stCamera.m_bActive) or (not pLocalPlayer) then
        g_stCamera.m_bActive = false;
        return;
    end


    draw.Color( 235, 64, 52, 255 )
    draw.OutlinedRect( camera_x_position, camera_y_position, camera_x_position + camera_width, camera_y_position + camera_height )
    draw.OutlinedRect( camera_x_position, camera_y_position - 20, camera_x_position + camera_width, camera_y_position )

    draw.Color( 130, 26, 17, 255 )
    draw.FilledRect( camera_x_position+1, camera_y_position - 19, camera_x_position + camera_width-1, camera_y_position-1 )

    draw.SetFont( font ); 
    draw.Color(255,255,255,255)

    local w, h = draw.GetTextSize( "sticky camera" )
    draw.Text(math.floor(camera_x_position + (camera_width - w)*0.5), camera_y_position - 16, "sticky camera");

    render.DrawScreenSpaceRectangle( g_stCamera.m_pMaterial, camera_x_position, camera_y_position, camera_width, camera_height, 0, 0, g_iCameraRenderWidth, g_iCameraRenderHeight, g_iCameraRenderWidth, g_iCameraRenderHeight );
end)
