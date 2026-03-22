-- Copyright 2010 Riccardo Belloli (belloli@email.it)
-- This file is a part of QDKP_V2 (see about.txt in the Addon's root folder)

--             ## СИСТЕМА РОЛЕЙ И БОНУСОВ ЗА РОЛИ ##
--

-- Таблица перевода имен боссов для системы бонусов за роли
local role_boss_translator = {
    -- Icecrown Citadel (ЦЛК)
    ["Лорд Ребрад"] = "Lord Marrowgar",
    ["Леди Смертный Шепот"] = "Lady Deathwhisper",
    ["Бой на кораблях"] = "Icecrown Gunship Battle",
    ["Завоеватель Дракономор"] = "Icecrown Gunship Battle",
    ["Саурфанг Смертоносный"] = "Deathbringer Saurfang",
    ["Трухлявый"] = "Festergut",
    ["Гниломорд"] = "Rotface",
    ["Профессор Мерзоцид"] = "Professor Putricide",
    ["Принц Валанар"] = "Prince Valanar",
    ["Кровавая королева Лана'тель"] = "Blood-Queen Lana'thel",
    ["Валитрия Сноходица"] = "Valithria Dreamwalker",
    ["Синдрагоса"] = "Sindragosa",
    ["Король-лич"] = "The Lich King",
    
    -- Ruby Sanctum (РС)
    ["Халион"] = "Halion",
    ["Халион Сумеречный Разрушитель"] = "Halion",
    
    -- Trial of the Crusader (Испытание крестоносца)
    ["Чудовища Нордскола"] = "Northrend Beasts",
    ["Лорд Джараксус"] = "Lord Jaraxxus",
    ["Чемпионы фракций"] = "Faction Champions",
    ["Валь'киры-близнецы"] = "The Twin Val'kyr",
    ["Эйдис Погибель Тьмы"] = "Eydis Darkbane",
    ["Эйдис, Погибель Тьмы"] = "Eydis Darkbane",
    ["Фьола Погибель Света"] = "Fjola Lightbane",
    ["Ануб'арак"] = "Anub'arak"
}

-- Функция для нормализации имени босса с использованием перевода
local function NormalizeBossName(bossName)
    if not bossName or type(bossName) ~= 'string' then
        return bossName
    end
    
    local normalized = role_boss_translator[bossName] or bossName
    
    if QDKP2bossEnglish then
        normalized = QDKP2bossEnglish[normalized] or normalized
    end
    
    QDKP2_Debug(3, "RoleBonus", "Нормализация имени босса: '" .. bossName .. "' -> '" .. normalized .. "'")
    return normalized
end

-- ==================== СИСТЕМА РОЛЕЙ ====================

-- Глобальная таблица для хранения ролей игроков
QDKP2_RolesDB = QDKP2_RolesDB or {}

-- Структура ролей
QDKP2_RoleConfig = {
    -- Автоматические роли (из талантов)
    AUTO = {
        TANK = {
            name = "Танк",
            displayName = "Танк",
            color = { r = 0, g = 0.5, b = 1 },
            priority = 5
        },
        HEAL = {
            name = "Хил",
            displayName = "Хил",
            color = { r = 0, g = 1, b = 0 },
            priority = 6
        },
        DD = {
            name = "Дпс",
            displayName = "Дпс",
            color = { r = 1, g = 0.3, b = 0.3 },
            priority = 9
        }
    },
    
    -- Ручные роли (BIS)
    MANUAL = {
        BIS = {
            name = "Бис",
            displayName = "Бис",
            color = { r = 1, g = 0.84, b = 0 },
            priority = 8
        }
    },
    
    -- Комбинированные роли для отображения
    DISPLAY = {
        BIS_TANK = {
            name = "Бис Танк",
            displayName = "Бис Танк",
            color = { r = 0, g = 0.2, b = 0.6 },
            priority = 3
        },
        BIS_HEAL = {
            name = "Бис Хил",
            displayName = "Бис Хил",
            color = { r = 0, g = 0.5, b = 0 },
            priority = 4
        },
        BIS_DD = {
            name = "Бис Дпс",
            displayName = "Бис Дпс",
            color = { r = 0.6, g = 0, b = 0 },
            priority = 7
        },
        BIS = {
            name = "Бис",
            displayName = "Бис",
            color = { r = 1, g = 0.84, b = 0 },
            priority = 8
        },
        TANK = {
            name = "Танк",
            displayName = "Танк",
            color = { r = 0, g = 0.5, b = 1 },
            priority = 5
        },
        HEAL = {
            name = "Хил",
            displayName = "Хил",
            color = { r = 0, g = 1, b = 0 },
            priority = 6
        },
        DD = {
            name = "Дпс",
            displayName = "Дпс",
            color = { r = 1, g = 0.3, b = 0.3 },
            priority = 9
        }
    },
    
    -- Бонусные роли (для начисления бонусов)
    BONUS = {
        BIS_TANK_HEAL = {
            name = "БИС ТАНК/ХИЛ",
            priority = 1
        },
        TANK_HEAL = {
            name = "ТАНК/ХИЛ",
            priority = 2
        },
        BIS = {
            name = "БИС",
            priority = 3
        }
    }
}

-- Хранилище ролей игроков
QDKP2_PlayerAutoRoles = {}      -- автоматические роли (из талантов)
QDKP2_PlayerManualRoles = {}    -- ручные роли (BIS)

-- ==================== ФУНКЦИИ УПРАВЛЕНИЯ РОЛЯМИ ====================

function QDKP2_GetAutoRole(playerName)
    return QDKP2_PlayerAutoRoles[playerName]
end

function QDKP2_SetAutoRole(playerName, role)
    if role then
        QDKP2_PlayerAutoRoles[playerName] = role
    else
        QDKP2_PlayerAutoRoles[playerName] = nil
    end
end

function QDKP2_GetManualRole(playerName)
    return QDKP2_PlayerManualRoles[playerName]
end

function QDKP2_SetManualRole(playerName, role)
    if role and role == "BIS" then
        QDKP2_PlayerManualRoles[playerName] = role
    else
        QDKP2_PlayerManualRoles[playerName] = nil
    end
end

function QDKP2_ClearManualRole(playerName)
    QDKP2_PlayerManualRoles[playerName] = nil
end

function QDKP2_SetManualRolesForPlayers(players, role)
    if not players or #players == 0 then return end
    
    for _, playerName in ipairs(players) do
        if role == "NONE" then
            QDKP2_ClearManualRole(playerName)
        else
            QDKP2_SetManualRole(playerName, role)
        end
    end
    
    QDKP2_SaveRoles()
    QDKP2_RefreshAll()
end

function QDKP2_ResetAllRoles()
    table.wipe(QDKP2_PlayerManualRoles)
    QDKP2_SaveRoles()
    QDKP2_RefreshAll()
end

-- Получение отображаемой роли игрока
function QDKP2_GetPlayerDisplayRole(playerName)
    local autoRole = QDKP2_PlayerAutoRoles[playerName]
    local manualRole = QDKP2_PlayerManualRoles[playerName]
    
    if manualRole == "BIS" then
        if autoRole == "TANK" then
            return "BIS_TANK"
        elseif autoRole == "HEAL" then
            return "BIS_HEAL"
        elseif autoRole == "DD" then
            return "BIS_DD"
        else
            return "BIS"
        end
    elseif autoRole then
        return autoRole
    end
    
    return nil
end

-- Получение названия роли для отображения
function QDKP2_GetPlayerRoleDisplayName(playerName)
    local roleKey = QDKP2_GetPlayerDisplayRole(playerName)
    if roleKey and QDKP2_RoleConfig.DISPLAY[roleKey] then
        return QDKP2_RoleConfig.DISPLAY[roleKey].displayName
    end
    return ""
end

-- Получение цвета роли
function QDKP2_GetPlayerRoleColor(playerName)
    local roleKey = QDKP2_GetPlayerDisplayRole(playerName)
    if roleKey and QDKP2_RoleConfig.DISPLAY[roleKey] then
        local color = QDKP2_RoleConfig.DISPLAY[roleKey].color
        return { r = color.r, g = color.g, b = color.b }
    end
    return { r = 1, g = 1, b = 1 }
end

-- Получение бонусной роли (для начисления бонусов)
function QDKP2_GetBonusRole(playerName)
    local autoRole = QDKP2_PlayerAutoRoles[playerName]
    local manualRole = QDKP2_PlayerManualRoles[playerName]
    
    if not autoRole and not manualRole then
        return nil
    end
    
    if manualRole == "BIS" then
        if autoRole == "TANK" or autoRole == "HEAL" then
            return "BIS_TANK_HEAL"
        elseif autoRole == "DD" then
            return "BIS"
        else
            return "BIS"
        end
    elseif autoRole == "TANK" or autoRole == "HEAL" then
        return "TANK_HEAL"
    end
    
    return nil
end

-- Получение приоритета роли для сортировки
function QDKP2_GetRolePriority(playerName)
    local roleKey = QDKP2_GetPlayerDisplayRole(playerName)
    if roleKey and QDKP2_RoleConfig.DISPLAY[roleKey] then
        return QDKP2_RoleConfig.DISPLAY[roleKey].priority
    end
    return 99
end

-- ==================== СОХРАНЕНИЕ РОЛЕЙ ====================

function QDKP2_SaveRoles()
    QDKP2_RolesDB = QDKP2_RolesDB or {}
    
    -- Сохраняем ручные роли
    for playerName, role in pairs(QDKP2_PlayerManualRoles) do
        QDKP2_RolesDB[playerName] = role
    end
    
    -- Удаляем записи для игроков без ручных ролей
    for playerName, _ in pairs(QDKP2_RolesDB) do
        if not QDKP2_PlayerManualRoles[playerName] then
            QDKP2_RolesDB[playerName] = nil
        end
    end
    
    QDKP2_Debug(2, "Roles", "Роли сохранены. Ручных записей: " .. tostring(QDKP2_CountManualRoles()))
end

function QDKP2_LoadRoles()
    if not QDKP2_RolesDB then
        QDKP2_RolesDB = {}
        QDKP2_Debug(2, "Roles", "База данных ролей инициализирована")
        return
    end
    
    QDKP2_PlayerManualRoles = {}
    for playerName, role in pairs(QDKP2_RolesDB) do
        if role == "BIS" then
            QDKP2_PlayerManualRoles[playerName] = role
        end
    end
    
    QDKP2_Debug(2, "Roles", "Роли загружены. Ручных записей: " .. tostring(QDKP2_CountManualRoles()))
end

function QDKP2_CountManualRoles()
    local count = 0
    if QDKP2_PlayerManualRoles then
        for _ in pairs(QDKP2_PlayerManualRoles) do
            count = count + 1
        end
    end
    return count
end

function QDKP2_ResetRolesOnSessionClose()
    local roleCount = 0
    
    if QDKP2_PlayerManualRoles then
        for _ in pairs(QDKP2_PlayerManualRoles) do
            roleCount = roleCount + 1
        end
        table.wipe(QDKP2_PlayerManualRoles)
    end
    
    if QDKP2_RolesDB then
        table.wipe(QDKP2_RolesDB)
    end
    
    if roleCount > 0 then
        QDKP2_Debug(2, "Roles", "Роли сброшены при закрытии сессии. Сброшено: " .. roleCount .. " ролей")
    end
    
    return roleCount > 0
end

-- ==================== АВТОМАТИЧЕСКОЕ ОПРЕДЕЛЕНИЕ РОЛЕЙ (LibGroupTalents) ====================

local function ConvertGTToQDKPRole(gtRole)
    if gtRole == "tank" then
        return "TANK"
    elseif gtRole == "healer" then
        return "HEAL"
    else
        return "DD"
    end
end

function QDKP2_UpdateUnitRole(unit)
    if not unit or not UnitExists(unit) then return end

    local name = UnitName(unit)
    if not name then return end

    local lib = LibStub:GetLibrary("LibGroupTalents-1.0", true)
    if not lib then return end

    local gtRole = lib:GetUnitRole(unit)
    if not gtRole then return end

    QDKP2_SetAutoRole(name, ConvertGTToQDKPRole(gtRole))
end

function QDKP2_ScanRaidRoles()
    local num = GetNumRaidMembers()
    for i = 1, num do
        QDKP2_UpdateUnitRole("raid" .. i)
    end
end

function QDKP2_InitTalentRoleSystem()
    local lib = LibStub:GetLibrary("LibGroupTalents-1.0", true)
    if not lib then
        QDKP2_Debug(1, "Roles", "LibGroupTalents не найден")
        return
    end

    lib.RegisterCallback(QDKP2_RoleCallbacks, "LibGroupTalents_RoleChange")
    lib.RegisterCallback(QDKP2_RoleCallbacks, "LibGroupTalents_Update")
end

-- Callback обработчик для LibGroupTalents
QDKP2_RoleCallbacks = {}
function QDKP2_RoleCallbacks:LibGroupTalents_RoleChange(event, guid, unit)
    QDKP2_UpdateUnitRole(unit)
    QDKP2_RefreshAll()
end

function QDKP2_RoleCallbacks:LibGroupTalents_Update(event, guid, unit)
    QDKP2_UpdateUnitRole(unit)
    QDKP2_RefreshAll()
end

-- ==================== МЕНЮ НАЗНАЧЕНИЯ РОЛЕЙ ====================

function QDKP2_ShowRoleMenu(selectedPlayers, menuFrame)
    local menu = {
        { text = "Назначение ролей", isTitle = true },
        { text = "Бис", 
          func = function() 
              QDKP2_SetManualRolesForPlayers(selectedPlayers, "BIS")
          end },
        { text = "Сбросить роль", 
          func = function() 
              QDKP2_SetManualRolesForPlayers(selectedPlayers, "NONE")
          end },
        { text = "Сбросить все роли", 
          func = function() 
              QDKP2_ResetAllRoles()
          end },
        { text = "" },
        { text = "Закрыть", 
          func = function() 
              CloseDropDownMenus() 
          end }
    }
    
    EasyMenu(menu, menuFrame, "cursor", 0, 0, "MENU")
end

-- ==================== СИСТЕМА БОНУСОВ ЗА РОЛИ ====================

QDKP2_RoleBonus = {
    enabled = true,
    config = {
        DD = {
            name = "ДД",
            color = { r = 1, g = 1, b = 1 }
        },
        BIS = {
            name = "БИС",
            color = { r = 1, g = 0.84, b = 0 },
            DKP_10N = 0,
            DKP_10H = 0,
            DKP_25N = 0,
            DKP_25H = 0
        },
        TANK_HEAL = {
            name = "ТАНК/ХИЛ", 
            color = { r = 0, g = 0.8, b = 1 },
            DKP_10N = 0,
            DKP_10H = 0,
            DKP_25N = 0,
            DKP_25H = 0
        },
        BIS_TANK_HEAL = {
            name = "БИС ТАНК/ХИЛ",
            color = { r = 0, g = 1, b = 0 },
            DKP_10N = 0,
            DKP_10H = 0,
            DKP_25N = 0,
            DKP_25H = 0
        }
    }
}

-- Таблица бонусов за роли по боссам
QDKP2_RoleBonusBosses = {
    -- Icecrown Citadel (ЦЛК)
    { name = "--Icecrown Citadel--" },
    
    { name = "Lord Marrowgar", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 10, BIS_25H = 25,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 25, TANK_HEAL_25H = 60, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 40, BIS_TANK_HEAL_25H = 90 },
    
    { name = "Lady Deathwhisper", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 10, BIS_25H = 25,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 25, TANK_HEAL_25H = 60, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 40, BIS_TANK_HEAL_25H = 90 },
    
    { name = "Icecrown Gunship Battle", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 10, BIS_25H = 25,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 25, TANK_HEAL_25H = 60, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 40, BIS_TANK_HEAL_25H = 90 },
    
    { name = "Deathbringer Saurfang", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 10, BIS_25H = 25,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 25, TANK_HEAL_25H = 60, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 40, BIS_TANK_HEAL_25H = 90 },
    
    { name = "Festergut", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 10, BIS_25H = 25,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 25, TANK_HEAL_25H = 60, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 40, BIS_TANK_HEAL_25H = 90 },
    
    { name = "Rotface", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 10, BIS_25H = 25,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 25, TANK_HEAL_25H = 60, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 40, BIS_TANK_HEAL_25H = 90 },
    
    { name = "Professor Putricide", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 10, BIS_25H = 25,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 25, TANK_HEAL_25H = 60, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 40, BIS_TANK_HEAL_25H = 90 },
    
    { name = "Prince Valanar", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 10, BIS_25H = 25,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 25, TANK_HEAL_25H = 60, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 40, BIS_TANK_HEAL_25H = 90 },
    
    { name = "Blood-Queen Lana'thel", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 10, BIS_25H = 25,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 25, TANK_HEAL_25H = 60, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 40, BIS_TANK_HEAL_25H = 90 },
    
    { name = "Valithria Dreamwalker", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 10, BIS_25H = 25,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 25, TANK_HEAL_25H = 60, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 40, BIS_TANK_HEAL_25H = 90 },
    
    { name = "Sindragosa", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 10, BIS_25H = 25,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 25, TANK_HEAL_25H = 60, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 40, BIS_TANK_HEAL_25H = 90 },
    
    { name = "The Lich King", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 90, BIS_25H = 125,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 125, TANK_HEAL_25H = 140, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 160, BIS_TANK_HEAL_25H = 210 },
    
    -- Ruby Sanctum (РС)
    { name = "----Ruby Sanctum----" },
    
    { name = "Halion", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 100, BIS_25H = 200,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 200, TANK_HEAL_25H = 400, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 300, BIS_TANK_HEAL_25H = 600 },

    -- Trial of the Crusader (ТоС)
    { name = "--------TotC--------" },
    
    { name = "Northrend Beasts", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 0, BIS_25H = 20,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 0, TANK_HEAL_25H = 60, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 0, BIS_TANK_HEAL_25H = 80 },
    
    { name = "Lord Jaraxxus", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 0, BIS_25H = 20,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 0, TANK_HEAL_25H = 60, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 0, BIS_TANK_HEAL_25H = 80 },

    { name = "Faction Champions", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 0, BIS_25H = 20,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 0, TANK_HEAL_25H = 60, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 0, BIS_TANK_HEAL_25H = 80 },

    { name = "Eydis Darkbane", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 0, BIS_25H = 20,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 0, TANK_HEAL_25H = 60, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 0, BIS_TANK_HEAL_25H = 80 },

    { name = "Anub'arak", 
        BIS_10N = 0, BIS_10H = 0,
        BIS_25N = 0, BIS_25H = 20,
        TANK_HEAL_10N = 0, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 0, TANK_HEAL_25H = 60, 
        BIS_TANK_HEAL_10N = 0, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 0, BIS_TANK_HEAL_25H = 80 },
    
    -- Ulduar
    { name = "-------Ulduar-------" },
    
    { name = "Flame Leviathan", 
        BIS_10N = 20, BIS_10H = 0,
        BIS_25N = 40, BIS_25H = 0,
        TANK_HEAL_10N = 25, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 55, TANK_HEAL_25H = 0, 
        BIS_TANK_HEAL_10N = 50, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 100, BIS_TANK_HEAL_25H = 0 },
    
    { name = "Ignis the Furnace Master", 
        BIS_10N = 20, BIS_10H = 0,
        BIS_25N = 40, BIS_25H = 0,
        TANK_HEAL_10N = 25, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 55, TANK_HEAL_25H = 0, 
        BIS_TANK_HEAL_10N = 50, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 100, BIS_TANK_HEAL_25H = 0 },
    
    { name = "Razorscale", 
        BIS_10N = 20, BIS_10H = 0,
        BIS_25N = 40, BIS_25H = 0,
        TANK_HEAL_10N = 25, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 55, TANK_HEAL_25H = 0, 
        BIS_TANK_HEAL_10N = 50, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 100, BIS_TANK_HEAL_25H = 0 },
    
    { name = "XT-002 Deconstructor", 
        BIS_10N = 20, BIS_10H = 0,
        BIS_25N = 40, BIS_25H = 0,
        TANK_HEAL_10N = 25, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 55, TANK_HEAL_25H = 0, 
        BIS_TANK_HEAL_10N = 50, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 100, BIS_TANK_HEAL_25H = 0 },
    
    { name = "The Assembly of Iron", 
        BIS_10N = 20, BIS_10H = 0,
        BIS_25N = 40, BIS_25H = 0,
        TANK_HEAL_10N = 25, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 55, TANK_HEAL_25H = 0, 
        BIS_TANK_HEAL_10N = 50, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 100, BIS_TANK_HEAL_25H = 0 },
    
    { name = "Kologarn", 
        BIS_10N = 20, BIS_10H = 0,
        BIS_25N = 40, BIS_25H = 0,
        TANK_HEAL_10N = 25, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 55, TANK_HEAL_25H = 0, 
        BIS_TANK_HEAL_10N = 50, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 100, BIS_TANK_HEAL_25H = 0 },
    
    { name = "Auriaya", 
        BIS_10N = 20, BIS_10H = 0,
        BIS_25N = 40, BIS_25H = 0,
        TANK_HEAL_10N = 25, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 55, TANK_HEAL_25H = 0, 
        BIS_TANK_HEAL_10N = 50, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 100, BIS_TANK_HEAL_25H = 0 },
    
    { name = "Hodir", 
        BIS_10N = 20, BIS_10H = 0,
        BIS_25N = 40, BIS_25H = 0,
        TANK_HEAL_10N = 25, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 55, TANK_HEAL_25H = 0, 
        BIS_TANK_HEAL_10N = 50, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 100, BIS_TANK_HEAL_25H = 0 },
    
    { name = "Thorim", 
        BIS_10N = 20, BIS_10H = 0,
        BIS_25N = 40, BIS_25H = 0,
        TANK_HEAL_10N = 25, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 55, TANK_HEAL_25H = 0, 
        BIS_TANK_HEAL_10N = 50, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 100, BIS_TANK_HEAL_25H = 0 },
    
    { name = "Freya", 
        BIS_10N = 20, BIS_10H = 0,
        BIS_25N = 40, BIS_25H = 0,
        TANK_HEAL_10N = 25, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 55, TANK_HEAL_25H = 0, 
        BIS_TANK_HEAL_10N = 50, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 100, BIS_TANK_HEAL_25H = 0 },
    
    { name = "Mimiron", 
        BIS_10N = 20, BIS_10H = 0,
        BIS_25N = 40, BIS_25H = 0,
        TANK_HEAL_10N = 25, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 55, TANK_HEAL_25H = 0, 
        BIS_TANK_HEAL_10N = 50, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 100, BIS_TANK_HEAL_25H = 0 },
    
    { name = "General Vezax", 
        BIS_10N = 20, BIS_10H = 0,
        BIS_25N = 40, BIS_25H = 0,
        TANK_HEAL_10N = 25, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 55, TANK_HEAL_25H = 0, 
        BIS_TANK_HEAL_10N = 50, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 100, BIS_TANK_HEAL_25H = 0 },
    
    { name = "Yogg-Saron", 
        BIS_10N = 30, BIS_10H = 0,
        BIS_25N = 60, BIS_25H = 0,
        TANK_HEAL_10N = 50, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 70, TANK_HEAL_25H = 0, 
        BIS_TANK_HEAL_10N = 50, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 100, BIS_TANK_HEAL_25H = 0 },
    
    { name = "Algalon the Observer", 
        BIS_10N = 30, BIS_10H = 0,
        BIS_25N = 60, BIS_25H = 0,
        TANK_HEAL_10N = 50, TANK_HEAL_10H = 0, 
        TANK_HEAL_25N = 70, TANK_HEAL_25H = 0, 
        BIS_TANK_HEAL_10N = 50, BIS_TANK_HEAL_10H = 0, 
        BIS_TANK_HEAL_25N = 100, BIS_TANK_HEAL_25H = 0 },
}

-- Функции для работы с бонусами
function QDKP2_GetRoleBonusForBoss(boss, difficulty)
    if not QDKP2_RoleBonus.enabled then return {} end
    
    difficulty = difficulty or "25N"
    local normalizedBoss = NormalizeBossName(boss)
    
    local bonuses = {}
    
    for _, bossData in ipairs(QDKP2_RoleBonusBosses) do
        if bossData.name == normalizedBoss then
            for roleKey, roleConfig in pairs(QDKP2_RoleBonus.config) do
                local bonusField = roleKey .. "_" .. difficulty
                local bonusAmount = bossData[bonusField]
                if bonusAmount and bonusAmount > 0 then
                    bonuses[roleKey] = {
                        amount = bonusAmount,
                        name = roleConfig.name,
                        color = roleConfig.color
                    }
                end
            end
            break
        end
    end
    
    return bonuses
end

function QDKP2_AwardRoleBonus(boss, difficulty)
    if not QDKP2_RoleBonus.enabled then
        QDKP2_Debug(2, "RoleBonus", "Бонусы за роли отключены")
        return
    end
    
    if not QDKP2_ManagementMode() then
        QDKP2_Debug(2, "RoleBonus", "Не в режиме управления")
        return
    end
    
    local bonuses = QDKP2_GetRoleBonusForBoss(boss, difficulty)
    if not bonuses or not next(bonuses) then
        QDKP2_Debug(2, "RoleBonus", "Нет бонусов за роли для " .. boss)
        return
    end
    
    local awardedPlayers = {}
    local totalAwarded = 0
    
    for i = 1, QDKP2_GetNumRaidMembers() do
        local name = QDKP2_GetRaidRosterInfo(i)
        if name and QDKP2_IsInGuild(name) then
            local bonusKey = QDKP2_GetBonusRole(name)
            
            if bonusKey and bonuses[bonusKey] then
                local bonusInfo = bonuses[bonusKey]
                local reason = string.format("Бонус %s за %s", bonusInfo.name, boss)
                
                QDKP2_AddTotals(name, bonusInfo.amount, 0, 0, reason)
                table.insert(awardedPlayers, {
                    name = name,
                    role = bonusInfo.name,
                    amount = bonusInfo.amount
                })
                totalAwarded = totalAwarded + bonusInfo.amount
                
                QDKP2_Debug(2, "RoleBonus", string.format("Начислен бонус %s DKP игроку %s за роль %s", 
                    bonusInfo.amount, name, bonusInfo.name))
            end
        end
    end
    
    if #awardedPlayers > 0 then
        local roleText = ""
        for _, player in ipairs(awardedPlayers) do
            roleText = roleText .. string.format("%s (%s: +%s) ", player.name, player.role, player.amount)
        end
        
        QDKP2log_Entry("RAID", string.format("Бонусы за роли за %s: %s", boss, roleText), QDKP2LOG_BOSS)
        QDKP2_Msg(QDKP2_COLOR_GREEN .. string.format("Начислены бонусы за роли за %s: %d игроков (+%d DKP)", 
            boss, #awardedPlayers, totalAwarded))
    end
    
    QDKP2_Events:Fire("DATA_UPDATED", "roster")
end

function QDKP2_RoleBonusSet(todo)
    if todo == "toggle" then
        if QDKP2_RoleBonus.enabled then
            QDKP2_RoleBonusSet("off")
        else
            QDKP2_RoleBonusSet("on")
        end
    elseif todo == "on" then
        QDKP2_RoleBonus.enabled = true
        QDKP2_Events:Fire("ROLEBONUS_ON")
        QDKP2_Msg(QDKP2_COLOR_GREEN .. "Бонусы за роли включены")
    elseif todo == "off" then
        QDKP2_RoleBonus.enabled = false
        QDKP2_Events:Fire("ROLEBONUS_OFF")
        QDKP2_Msg(QDKP2_COLOR_YELLOW .. "Бонусы за роли выключены")
    end
end

function QDKP2_IsRoleBonusEnabled()
    return QDKP2_RoleBonus.enabled
end

function QDKP2_GetRoleBonusConfig()
    return QDKP2_RoleBonus.config
end

function QDKP2_GetRoleBonusBosses()
    return QDKP2_RoleBonusBosses
end

function QDKP2_SetRoleBonusBosses(newBosses)
    if type(newBosses) == "table" then
        QDKP2_RoleBonusBosses = newBosses
        QDKP2_Msg("Таблица бонусов за роли обновлена")
        QDKP2_Events:Fire("ROLEBONUS_CONFIG_UPDATED")
    end
end

function QDKP2_GetPlayerRoleBonus(playerName, boss, difficulty)
    if not QDKP2_RoleBonus.enabled then return 0 end
    
    local bonusKey = QDKP2_GetBonusRole(playerName)
    if not bonusKey then return 0 end
    
    local bonuses = QDKP2_GetRoleBonusForBoss(boss, difficulty)
    return bonuses[bonusKey] and bonuses[bonusKey].amount or 0
end

-- ==================== ИНИЦИАЛИЗАЦИЯ ====================

function QDKP2_InitRoleSystem()
    QDKP2_LoadRoles()
    QDKP2_InitTalentRoleSystem()
    QDKP2_ScanRaidRoles()
    
    QDKP2_Debug(1, "RoleBonus", "Система ролей и бонусов за роли инициализирована")
end

-- Регистрируем события
local function RegisterRoleEvents()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_LOGOUT")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("RAID_ROSTER_UPDATE")
    
    frame:SetScript("OnEvent", function(frame, event, ...)
        if event == "PLAYER_LOGOUT" then
            QDKP2_SaveRoles()
            QDKP2_Debug(2, "Roles", "Роли сохранены при выходе из игры")
        elseif event == "PLAYER_ENTERING_WORLD" then
            QDKP2_LoadRoles()
            QDKP2_InitTalentRoleSystem()
            QDKP2_ScanRaidRoles()
        elseif event == "RAID_ROSTER_UPDATE" then
            QDKP2_ScanRaidRoles()
        end
    end)
end

-- Запуск инициализации
RegisterRoleEvents()
QDKP2_InitRoleSystem()