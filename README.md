![Alt text](https://forgejo.neoeden.org/ergo/mod-all-classes-hunter-pet/raw/branch/main/Untitled.png)

## Hunter pets for all classes in Azerothcore.

This is a mod that requires changes in both Azerothcore and the WOTLK 3.3.5a client (Editing of the wow.exe binary with a disassembler/decompiler)

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
❌ Stable Master\
❌ Pet Trainer\
❓ Simultaneous Warlock/Mage/Death Knight pet + Hunter pet\
❓ Taming Exotic pets (Beast Mastery)

---

### If you just want to download the files, overwrite your non-modded files, and play:

[Download ]() (WIP)

[Download wow.exe]() (WIP)

### If you want to do the modifications yourself:

---

## **AZEROTHCORE MODIFICATIONS**

### **1 - Giving characters pet-related spells:**

No matter the mechanism you choose to teach characters the hunter pet skills, you need this two lines on your worldserver.conf:

```PlayerStart.CustomSpells = 1```

```ValidateSkillLearnedBySpells = 0```

There are multiple ways you can give the characters in your server the ability to use hunter pet spells, here I specify two ways, the first gives all characters the spells on character creation, the second gives them the spells when they reach level 10, you can do it in a different way if you like.

**On character creation:**

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
(0, 0xFFFF, 5149, 'Beast Training');
```

This will make it so that all characters of all classes are taught the spells needed for handling hunter pets at character creation.

**On level 10:**



In order to use the Stable Master to store pets, your character needs to have stable_slots = 4 in the database, for hunters this happens by default but for other classes it is normally 0, by running this query you will make it so that the database always assigns the value 4 to all newly created characters.

```
ALTER TABLE `characters` MODIFY `stable_slots` TINYINT UNSIGNED NOT NULL DEFAULT 4;
```

### **2 - Edit the following .cpp files in your Azerothcore server directory:**

**/src/server/game/Entities/Player/Player.cpp**

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

## **CLIENT MODIFICATIONS**

### **1 - Edit the wow.exe binary in your client directory using a disassembler/decompiler:**

GetPetPersonalityRow
NOP 17 bytes starting from 0x0071F3BF

HasPetUI
NOP 21 bytes starting from 0x005D3C10





WORK IN PROGRESS
