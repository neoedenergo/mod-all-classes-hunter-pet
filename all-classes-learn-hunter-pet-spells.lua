local function OnLevelChanged(event, player, oldLevel)
    if player:GetLevel() == 10 and oldLevel < 10 then
        -- Teach pet-related spells at level 10
        player:LearnSpell(1515) -- Tame Beast
        player:LearnSpell(883)  -- Call Pet
        player:LearnSpell(2641) -- Dismiss Pet
        player:LearnSpell(6991) -- Feed Pet
        player:LearnSpell(982)  -- Revive Pet
        player:LearnSpell(5149)  -- Beast Training
        player:LearnSpell(1462)  -- Beast Lore
        player:SendBroadcastMessage("You are now level 10 and can tame beasts.")
    end
    if player:GetLevel() == 12 and oldLevel < 12 then
        -- Teach Mend Pet at level 12
        player:LearnSpell(136)  -- Mend Pet
        player:SendBroadcastMessage("You are now level 12 and can use Mend Pet.")
    end
    if player:GetLevel() == 60 and oldLevel < 60 then
        -- Teach Beast Mastery at level 60
        player:LearnSpell(53270)  -- Beast Mastery (allows taming exotic pets)
        player:SendBroadcastMessage("You are now level 60 and can tame exotic pets.")
    end
end

RegisterPlayerEvent(13, OnLevelChanged) -- 13 is PLAYER_EVENT_ON_LEVEL_CHANGE