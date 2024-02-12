------------------
--   Const
local QBCore = exports['qb-core']:GetCoreObject()

--   Variable
local menu = {}
local QbMenu = {}
------------------
local function Open_menu(data)
     if Config.menu == 'keep-menu' then
          menu:withdraw_menu(data)
          return
     end
     QbMenu:withdraw_menu(data)
end

AddEventHandler('mVeinPaycheck:menu:Open_menu', function()
     QBCore.Functions.TriggerCallback('mVeinPaycheck:server:account_information', function(result)
          if result then
               Open_menu(result)
               return
          end
          QBCore.Functions.Notify(Lang:t('error.failed_to_open_menu'), "error")
     end)
end)
------------------
--   functions
------------------
local function format_int(number)
     local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
     int = int:reverse():gsub("(%d%d%d)", "%1,")
     return minus .. int:reverse():gsub("^,", "") .. fraction
end

local function withdraw_all(maximum)
     if maximum == 0 then
          QBCore.Functions.Notify(Lang:t('info.no_money_in_account'), "primary")
          return
     end
     QBCore.Functions.TriggerCallback('mVeinPaycheck:server:withdraw_all', function(result, reason)
          if result then
               Speach('thanks')
               TriggerEvent('animations:client:EmoteCommandStart', { "ID" })
               QBCore.Functions.Notify(Lang:t('success.successful_withdraw') .. reason .. '$', "success")
          else
               QBCore.Functions.Notify(Lang:t('error.withdraw_failed') .. reason, "error")
          end
     end)
end

local function withdraw_amount(maximum)
     if maximum == 0 then
          QBCore.Functions.Notify(Lang:t('info.no_money_in_account'), "primary")
          return
     end
     local inputData = exports['qb-input']:ShowInput({
          header = Lang:t('menu.withdraw_amount.header'),
          submitText = Lang:t('menu.withdraw_amount.submitText'),
          inputs = {
               {
                    type = 'text',
                    isRequired = true,
                    name = 'amount',
                    text = Lang:t('menu.withdraw_amount.textbox') .. maximum
               },
          }
     })
     if inputData then
          if not inputData.amount then return end
          local amount = tonumber(inputData.amount)
          if type(amount) == "string" then
               QBCore.Functions.Notify(Lang:t('error.bad_input'), "error")
               return
          end
          if not (0 < amount) then
               QBCore.Functions.Notify(Lang:t('error.money_amount_more_than_zero'), "error")
               withdraw_amount(maximum)
               return
          end

          if amount >= math.maxinteger then
               QBCore.Functions.Notify(Lang:t('error.can_not_withdraw_much') .. amount, "error")
               return
          end

          if not (amount <= maximum) and amount < math.maxinteger then
               QBCore.Functions.Notify(Lang:t('error.can_not_withdraw_much') .. amount, "error")
               withdraw_amount(maximum)
               return
          end

          QBCore.Functions.TriggerCallback('mVeinPaycheck:server:withdraw_amount', function(result, reason)
               if result then
                    TriggerEvent('animations:client:EmoteCommandStart', { "ID" })
                    QBCore.Functions.Notify(Lang:t('success.successful_withdraw') .. reason .. '$', "success")
                    Speach('thanks')
               else
                    QBCore.Functions.Notify(Lang:t('error.withdraw_failed') .. reason, "error")
               end
          end, inputData.amount)
     end
end

------------------
--   keep-menu
------------------

function menu:withdraw_menu(data)
     if data == nil then return end
     Speach('hi')
     TriggerEvent('animations:client:EmoteCommandStart', { "bekle10" })
     local money = string.format(Lang:t('menu.withdraw_menu.money_string'), format_int(data.money))
     local Menu = {
          {
               header = Lang:t('menu.withdraw_menu.header'),
               icon = 'fa-solid fa-credit-card',
               -- disabled = true
          },
          {
               header = Lang:t('menu.withdraw_menu.account_Information'),
               subheader = money,
               icon = 'fa-solid fa-hand-holding-dollar',
               submenu = false,
          },
          {
               header = Lang:t('menu.withdraw_menu.withdraw_all'),
               icon = 'fa-solid fa-money-bill-transfer',
               args = { 1 },
               submenu = false,
          },
          {
               header = Lang:t('menu.withdraw_menu.withdraw_amount'),
               icon = 'fa-solid fa-arrow-up-wide-short',
               args = { 2 },
               submenu = true,
          },
          {
               header = Lang:t('menu.withdraw_menu.transaction_history'),
               icon = 'fa-solid fa-clock-rotate-left',
               args = { 3 },
               submenu = true,
          },
          {
               header = Lang:t('menu.leave'),
               event = "keep-menu:closeMenu",
               leave = true
          }
     }

     local req = exports['keep-menu']:createMenu(Menu)

     if req == 1 then
          -- Withdraw All
          withdraw_all(data.money)
          return
     elseif req == 2 then
          -- Withdraw Amount
          withdraw_amount(data.money)
          return
     elseif req == 3 then
          TriggerEvent('animations:client:EmoteCommandStart', { "not" })
          QBCore.Functions.TriggerCallback('mVeinPaycheck:server:get_logs', function(result)
               menu:logs_menu(result)
          end)
          return
     end
     TriggerEvent('animations:client:EmoteCommandStart', { "c" })
end

function menu:logs_menu(data)
     if data == nil then return end
     Speach('whatever')

     local Menu = {
          {
               header = Lang:t('menu.logs_menu.paycheck_logs'),
               icon = 'fa-solid fa-list',
               -- disabled = true
          },
          {
               header = Lang:t('menu.leave'),
               event = "keep-menu:closeMenu",
               leave = true
          }
     }

     for key, transaction in pairs(data) do
          local icon = ''
          local header = ''
          local metadata = json.decode(transaction.metadata)
          local subheader = Lang:t('menu.logs_menu.before')
          local footer = Lang:t('menu.logs_menu.after')
          subheader = string.format(subheader, format_int(metadata.account.old_value))
          footer = string.format(footer, format_int(metadata.account.current_value))

          if transaction.state == true then
               header = string.format(Lang:t('menu.logs_menu.recived'), format_int(transaction.amount))
               if metadata.desc.source then
                    if metadata.desc.source.name then
                         header = header .. Lang:t('menu.logs_menu.to') .. (metadata.desc.source.name or "")
                    end
                    if metadata.desc.source.job then
                         header = header .. Lang:t('menu.logs_menu.from') .. (metadata.charinfo.firstname.. " " ..metadata.charinfo.lastname or "")
                    end
               end
               icon = "fa-solid fa-arrow-right-to-bracket"

          else
               header = string.format(Lang:t('menu.logs_menu.withdraw'), format_int(transaction.amount))
               if metadata.desc.source then
                    if metadata.desc.source.name then
                         header = header .. Lang:t('menu.logs_menu.to') .. (metadata.desc.source.name or "")
                    end
                    if metadata.desc.source.job then
                         header = header .. Lang:t('menu.logs_menu.from') .. (metadata.charinfo.firstname.. " " ..metadata.charinfo.lastname or "")
                    end
               end
               icon = "fa-solid fa-arrow-right-from-bracket"
          end

          Menu[#Menu + 1] = {
               header = header,
               subheader = subheader,
               footer = footer,
               icon = icon
          }
     end
     exports['keep-menu']:createMenu(Menu)
     TriggerEvent('animations:client:EmoteCommandStart', { "c" })
end

------------------
--   qb-menu
------------------

function QbMenu:withdraw_menu(data)
     if data == nil then return end
     Speach('hi')
     TriggerEvent('animations:client:EmoteCommandStart', { "bekle10" })
     local money = string.format(Lang:t('menu.withdraw_menu.money_string'), format_int(data.money))
     local Menu = {
          {
               header = Lang:t('menu.withdraw_menu.header'),
               icon = 'fa-solid fa-credit-card',
               disabled = true
          },
          {
               header = Lang:t('menu.withdraw_menu.account_Information'),
               txt = money,
               icon = 'fa-solid fa-hand-holding-dollar',
          },
          {
               header = Lang:t('menu.withdraw_menu.withdraw_all'),
               icon = 'fa-solid fa-money-bill-transfer',
               params = {
                    event = 'mVeinPaycheck:client:function_caller',
                    args = { id = 1, money = data.money },
               }
          },
          {
               header = Lang:t('menu.withdraw_menu.withdraw_amount'),
               icon = 'fa-solid fa-arrow-up-wide-short',
               params = {
                    event = 'mVeinPaycheck:client:function_caller',
                    args = { id = 2, money = data.money },
               }
          },
          {
               header = Lang:t('menu.withdraw_menu.transaction_history'),
               icon = 'fa-solid fa-clock-rotate-left',
               params = {
                    event = 'mVeinPaycheck:client:function_caller',
                    args = { id = 3, money = data.money },
               }
          },
          {
               header = Lang:t('menu.leave'),
               icon = 'fa-solid fa-circle-xmark',
               params = {
                    event = "mVeinPaycheck:client:close_menu",
               }
          }
     }

     exports['qb-menu']:openMenu(Menu)

end

AddEventHandler('mVeinPaycheck:client:function_caller', function(data)
     TriggerEvent('animations:client:EmoteCommandStart', { "c" })
     if data.id == 1 then
          -- Withdraw All
          withdraw_all(data.money)
          return
     elseif data.id == 2 then
          -- Withdraw Amount
          withdraw_amount(data.money)
          return
     elseif data.id == 3 then
          QBCore.Functions.TriggerCallback('mVeinPaycheck:server:get_logs', function(result)
               QbMenu:logs_menu(result)
          end)
          return
     end
end)

function QbMenu:logs_menu(data)
     if data == nil then return end
     Speach('whatever')
     TriggerEvent('animations:client:EmoteCommandStart', { "notepad" })
     local Menu = {
          {
               header = Lang:t('menu.logs_menu.paycheck_logs'),
               icon = 'fa-solid fa-list',
               disabled = true
          },
          {
               header = Lang:t('menu.leave'),
               icon = 'fa-solid fa-circle-xmark',
               params = {
                    event = "mVeinPaycheck:client:close_menu",
               }
          }
     }

     for key, transaction in pairs(data) do
          local icon = ''
          local header = ''
          local metadata = json.decode(transaction.metadata)
          local subheader = Lang:t('menu.logs_menu.before')
          local footer = Lang:t('menu.logs_menu.after')
          subheader = string.format(subheader, format_int(metadata.account.old_value))
          footer = string.format(footer, format_int(metadata.account.current_value))

          if transaction.state == true then
               header = string.format(Lang:t('menu.logs_menu.recived'), format_int(transaction.amount))
               if metadata.desc.source then
                    if metadata.desc.source.name then
                         header = header .. Lang:t('menu.logs_menu.to') .. (metadata.desc.source.name or "")
                    end
                    if metadata.desc.source.job then
                         header = header .. Lang:t('menu.logs_menu.from') .. (metadata.desc.source.job or "")
                    end
               end
               icon = "fa-solid fa-arrow-right-to-bracket"

          else
               header = string.format(Lang:t('menu.logs_menu.withdraw'), format_int(transaction.amount))
               if metadata.desc.source then
                    if metadata.desc.source.name then
                         header = header .. Lang:t('menu.logs_menu.to') .. (metadata.desc.source.name or "")
                    end
                    if metadata.desc.source.job then
                         header = header .. Lang:t('menu.logs_menu.from') .. (metadata.desc.source.job or "")
                    end
               end
               icon = "fa-solid fa-arrow-right-from-bracket"
          end

          Menu[#Menu + 1] = {
               header = header,
               txt = subheader .. ' | ' .. footer,
               icon = icon
          }
     end
     exports['qb-menu']:openMenu(Menu)
end

AddEventHandler('mVeinPaycheck:client:close_menu', function()
     TriggerEvent('qb-menu:closeMenu')
end)

AddEventHandler('qb-menu:closeMenu', function()
     if not GetCurrentResourceName() == 'mVeinPaycheck' then
          return
     end
     TriggerEvent('animations:client:EmoteCommandStart', { "c" })
end)



local PED = nil
local function setPedVariation(pedHnadle, variation)
     for componentId, v in pairs(variation) do
          if IsPedComponentVariationValid(pedHnadle, componentId, v.drawableId, v.textureId) then
               SetPedComponentVariation(pedHnadle, componentId, v.drawableId, v.textureId)
          end
     end
end

function GETPED()
     return PED
end

function SETPED(ped)
     PED = ped
end

local function spawn_ped(data)
     RequestModel(data.model)
     while not HasModelLoaded(data.model) do
          Wait(0)
     end

     if type(data.model) == 'string' then data.model = GetHashKey(data.model) end
     -- local ped = exports["tgiann-base"]:pedcreate("paycheck", data.model, data.coords.x, data.coords.y, data.coords.z -0.4,  165.5)
     local ped = CreatePed(1, data.model, data.coords, data.networked or false, true)

     if data.variant then setPedVariation(ped, data.variant) end
     if data.freeze then FreezeEntityPosition(ped, true) end
     if data.invincible then SetEntityInvincible(ped, true) end
     if data.blockevents then SetBlockingOfNonTemporaryEvents(ped, true) end
     if data.animDict and data.anim then
          RequestAnimDict(data.animDict)
          while not HasAnimDictLoaded(data.animDict) do
               Wait(0)
          end

          if type(data.anim) == "table" then
               CreateThread(function()
                    while true do
                         local anim = data.anim[math.random(0, #data.anim)]
                         ClearPedTasks(ped)
                         TaskPlayAnim(ped, data.animDict, anim, 8.0, 0, -1, data.flag or 1, 0, 0, 0, 0)
                         SETPED(ped)
                         Wait(7000)
                    end
               end)
          else
               TaskPlayAnim(ped, data.animDict, data.anim, 8.0, 0, -1, data.flag or 1, 0, 0, 0, 0)
          end
     end

     if data.scenario then
          SetPedCanPlayAmbientAnims(ped, true)
          TaskStartScenarioInPlace(ped, data.scenario, 0, true)
     end

     if data.voice then
          SetAmbientVoiceName(ped, 'A_F_Y_BUSINESS_01_WHITE_FULL_01')
     end
     SETPED(ped)
end

local function makeCore()
     if PED then DeleteEntity(PED) end
     CreateThread(function()
          local coord = Config.intraction.npc.coords
          local vec3_coord = vector3(coord.x, coord.y, coord.z)
          PED = spawn_ped(Config.intraction.npc)

          exports['qb-target']:AddBoxZone("mVein_paycheck", vec3_coord, Config.intraction.box.l, Config.intraction.box.w,
               {
                    name = "mVein_paycheck",
                    heading = Config.intraction.box.heading,
                    debugPoly = false,
                    minZ = coord.z + Config.intraction.box.minz_offset,
                    maxZ = coord.z + Config.intraction.box.maxz_offset,
               }, {
               options = {
                    {
                         event = "mVeinPaycheck:menu:Open_menu",
                         icon = "fa-solid fa-credit-card",
                         label = Lang:t('menu.qb_target_label'),
                    },
               },
               distance = 2.0
          })
     end)
end

AddEventHandler('onResourceStart', function(resourceName)
     if (GetCurrentResourceName() ~= resourceName) then return end
     makeCore()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    makeCore()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
    PlayerData.job = job
end)

AddEventHandler('onResourceStop', function(resourceName)
     if resourceName ~= GetCurrentResourceName() then
          return
     end
     DeleteEntity(PED)
end)


