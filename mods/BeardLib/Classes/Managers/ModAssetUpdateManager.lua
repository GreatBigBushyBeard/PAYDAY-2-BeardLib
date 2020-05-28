ModAssetUpdateManager = ModAssetUpdateManager or class()
ModAssetUpdateManager._registered_updates = {}
ModAssetUpdateManager._ready_for_update = true
function ModAssetUpdateManager:init()
    self._data = {}
    self:load_manager_file()
end

function ModAssetUpdateManager:UpdatesIgnored(mod)
    return mod:GetSetting("IgnoreUpdates") == true
end

function ModAssetUpdateManager:RegisterUpdate(func)
    table.insert(self._registered_updates, func)
end

function ModAssetUpdateManager:IsReadyForUpdate()
    return self._ready_for_update
end

function ModAssetUpdateManager:PrepareForUpdate()
    self._ready_for_update = true
end

function ModAssetUpdateManager:Update(t, dt)
    if self._ready_for_update and next(self._registered_updates) then
        self._ready_for_update = false
        table.remove(self._registered_updates, 1)()
    end
end

--Unused
function ModAssetUpdateManager:SetUpdatesIgnored() end
function ModAssetUpdateManager:CheckUpdateStatus() end
function ModAssetUpdateManager:SetUpdateStatus() end
function ModAssetUpdateManager:save_manager_file() end
function ModAssetUpdateManager:load_manager_file() end

BeardLib:RegisterManager("asset_update", ModAssetUpdateManager)