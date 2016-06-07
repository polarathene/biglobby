-- Disable achievement progress if lobby set(not active) size is greater than 4 players.
-- This allows for seamless mode with regular lobbies.

local orig__AchievmentManager = {}
orig__AchievmentManager.award = AchievmentManager.award
orig__AchievmentManager._give_reward = AchievmentManager._give_reward
orig__AchievmentManager.award_progress = AchievmentManager.award_progress
orig__AchievmentManager.award_steam = AchievmentManager.award_steam
orig__AchievmentManager.steam_unlock_result = AchievmentManager.steam_unlock_result

function AchievmentManager:disable_achievements()
    local m_session = managers.network:session()
    local isRegularAmount = m_session and (m_session:amount_of_players() <= 4)
    -- `managers.network:session()` is here to prevent false positive, you should
    -- be able to unlock achievements while not in a game and have the mod enabled
    local isRegularSize = m_session and BigLobbyGlobals:is_small_lobby()

    return isRegularAmount or isRegularSize
end

function AchievmentManager.award(self, ...)
    if not self:disable_achievements() then
        orig__AchievmentManager.award(self, ...)
    end
end

function AchievmentManager._give_reward(self, ...)
    if not self:disable_achievements() then
        orig__AchievmentManager._give_reward(self, ...)
    end
end

function AchievmentManager.award_progress(self, ...)
    if not self:disable_achievements() then
        orig__AchievmentManager.award_progress(self, ...)
    end
end

function AchievmentManager.award_steam(self, ...)
    if not self:disable_achievements() then
        orig__AchievmentManager.award_steam(self, ...)
    end
end


-- Original is defined in dot notation, presumably doesn't expect self to be
-- passed in as first param?
function AchievmentManager.steam_unlock_result(...)
    if not AchievmentManager:disable_achievements() then
        orig__AchievmentManager.steam_unlock_result(...)
    end
end
