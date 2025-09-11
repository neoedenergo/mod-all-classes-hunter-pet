![ACHP](https://forgejo.neoeden.org/ergo/mod-all-classes-hunter-pet/raw/branch/main/ACHP.png)

# Hunter pets for all classes in Azerothcore.

This mod was made in collaboration with Uniquisher.

Thanks to [SatyPardus](https://github.com/SatyPardus) for the reverse engineering of the client's binary.

---

✅ Pet-related spells for all classes\
✅ Taming beasts\
✅ Pet talents\
✅ Pet leveling\
✅ Pet skills\
✅ Pet renaming\
✅ Pet feeding and loyalty level\
✅ Taming Exotic pets (Beast Mastery)\
❌ Stable Master\
❌ Pet Trainer\
❓ Simultaneous Warlock/Mage/Death Knight pet + Hunter pet

---

The mod requires modifications on your Azerothcore server, and if you want to be able to see pet happiness and diet information then you will need to modify your client as well, that is explained later.

# **AZEROTHCORE MODIFICATIONS**

## **1 - Giving characters pet-related spells:**

No matter the mechanism you choose to teach characters the hunter pet skills, you need to have this line on your worldserver.conf:

``ValidateSkillLearnedBySpells = 0``

There are multiple ways you can give the characters in your server the ability to use hunter pet spells, here I specify two ways, the first gives all characters the spells on character creation, the second gives them the spells when they reach level 10, 12 and 60 according to blizzlike hunter progression, you can do it in a different way if you like.


### **- On character creation:**

Put this line on your worldserver.conf file:

``PlayerStart.CustomSpells = 1``

Run this SQL query on your acore_world database:

```
INSERT INTO playercreateinfo_spell_custom (racemask, classmask, Spell, Note) VALUES
(0, 0xFFFF, 1515, 'Tame Beast'),
(0, 0xFFFF, 883, 'Call Pet 1'),
(0, 0xFFFF, 2641, 'Dismiss Pet'),
(0, 0xFFFF, 982, 'Revive Pet'),
(0, 0xFFFF, 136, 'Mend Pet'),
(0, 0xFFFF, 6991, 'Feed Pet'),
(0, 0xFFFF, 1462, 'Beast Lore'),
(0, 0xFFFF, 5149, 'Beast Training'),
(0, 0xFFFF, 53270, 'Beast Mastery');
```

This will make it so that all characters of all classes are taught all spells needed for handling hunter pets at character creation.


### **- On level 10, 12 and 60:**

This way characters will automatically learn spells to handle pets at level 10, then at level 12 they will learn Mend Pet, and at level 60 they will learn Beast Mastery which allows them to tame exotic pets.

You will need to install the Eluna module for Azerothcore: [https://github.com/azerothcore/mod-eluna](https://github.com/azerothcore/mod-eluna)

Then download this lua script: [all-classes-learn-hunter-pet-spells.lua](https://forgejo.neoeden.org/ergo/mod-all-classes-hunter-pet/src/branch/main/all-classes-learn-hunter-pet-spells.lua) and put it in the ``/env/dist/bin/lua_scripts`` directory.


## **2 - Edit the following .cpp files:**

**/src/server/game/Entities/Player/Player.cpp**

| Before               | After               |
| ---------------------- | ---------------------- |
| test1 | test2 |


1207
    // show pet at selection character in character list only for non-ghost character
    if (result && !(playerFlags & PLAYER_FLAGS_GHOST) && (plrClass == CLASS_WARLOCK || plrClass == CLASS_HUNTER || (plrClass == CLASS_DEATH_KNIGHT && (fields[21].Get<uint32>()&PLAYER_EXTRA_SHOW_DK_PET))))
    {


13668 ?
                LOG_ERROR("entities.player", "Player {} (GUID: {}), has skill ({}) that is invalid for the race/class combination (Race: {}, Class: {}). Will be deleted.",
                    GetName(), GetGUID().GetCounter(), skill, getRace(), getClass());

                // Mark skill for deletion in the database
                mSkillStatus.insert(SkillStatusMap::value_type(skill, SkillStatusData(0, SKILL_DELETED)));
                continue;
            }

14250

    if (IsClass(CLASS_HUNTER, CLASS_CONTEXT_PET))
    {
        return true;
    }

2140 ?
    if (npcflagmask & (UNIT_NPC_FLAG_TRAINER | UNIT_NPC_FLAG_TRAINER_CLASS) && creature->GetCreatureTemplate()->trainer_type == TRAINER_TYPE_CLASS && !IsClass((Classes)creature->GetCreatureTemplate()->trainer_class, CLASS_CONTEXT_CLASS_TRAINER))
        return nullptr;


14725

    stmt->SetData(index++, 4);


**/src/server/game/Entities/Player/PlayerGossip.cpp**

                case GOSSIP_OPTION_UNLEARNPETTALENTS:
                    if (!GetPet() || GetPet()->getPetType() != HUNTER_PET || GetPet()->m_spells.size() <= 1 || creature->GetCreatureTemplate()->trainer_type != TRAINER_TYPE_PETS || creature->GetCreatureTemplate()->trainer_class != CLASS_HUNTER)
                        canTalk = false;
                    break;

case GOSSIP_OPTION_STABLEPET:
                    if (!IsClass(CLASS_HUNTER, CLASS_CONTEXT_PET))
                        canTalk = false;
                    break;

**/src/server/game/Entities/Pet/Pet.cpp**

1049

                else if (owner->IsClass(CLASS_HUNTER, CLASS_CONTEXT_PET))
                {
                    petType = HUNTER_PET;
                }


1081 ? 

    if (!owner->IsClass(CLASS_HUNTER, CLASS_CONTEXT_PET) && cinfo->BaseAttackTime >= 1000)
        attackTime = cinfo->BaseAttackTime;


**/src/server/game/Entities/Creature/Creature.cpp**

1286

        case TRAINER_TYPE_PETS:
            if (m_creatureInfo->trainer_class && !player->IsClass((Classes)m_creatureInfo->trainer_class, CLASS_CONTEXT_CLASS_TRAINER))
            {
                if (npcFlags)
                    *npcFlags &= ~UNIT_NPC_FLAG_TRAINER_CLASS;

                return false;
            }
            break;

**/src/server/game/Handlers/PetHandler.cpp**

bool WorldSession::CheckStableMaster(ObjectGuid guid)
{
    // spell case or GM
    if (guid == GetPlayer()->GetGUID())
    {
        if (!GetPlayer()->IsGameMaster() && !GetPlayer()->HasOpenStableAura())
        {
            LOG_DEBUG("network.opcode", "Player ({}) attempt open stable in cheating way.", guid.ToString());
            return false;
        }
    }
    // stable master case
    else
    {
        if (!GetPlayer()->GetNPCIfCanInteractWith(guid, UNIT_NPC_FLAG_STABLEMASTER))
        {
            LOG_DEBUG("network.opcode", "Stablemaster ({}) not found or you can't interact with him.", guid.ToString());
            return false;
        }
    }
    return true;
}

**/src/server/game/Spells/SpellEffects.cpp**

3103

    if (!m_caster->IsClass(CLASS_HUNTER, CLASS_CONTEXT_PET))
        return;





---

# **CLIENT MODIFICATIONS**

## **1 - Edit the wow.exe binary in your client directory using a disassembler/decompiler:**

GetPetPersonalityRow
NOP 17 bytes starting from 0x0071F3BF

HasPetUI
NOP 21 bytes starting from 0x005D3C10





WORK IN PROGRESS
