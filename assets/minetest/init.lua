-- Adresářová struktura módu::
-- mymod
-- ├── textures         -- adresář s texturami (formát png, doporučené
-- │   │                                        rozlišení 32x32 či 16x16)
-- │   └── mymod_node.png
-- ├── sounds           -- adresář se zvuky (ogg formát)
-- │   └── mymod_sound.ogg
-- ├── init.lua         -- inicializace módu (vstupní bod - entry-point)
-- └── mod.conf         -- metadata (informace o módu)



-- Definice noveho objektu
-- https://minetest.gitlab.io/minetest/definition-tables/#node-definition
minetest.register_node(jmeno, vlastnosti)
minetest.register_node(
    -- jmeno - skládá se z prefixu a jména bločku, prefix by měl být shodný s
    --         názvem módu, neměl by obsahovat háčky, čárky, mezery ani jiné
    --         speciální znaky, maximálně "_", např:
    --             "mymod:node", "mymod:alzak", "mymod:dlouhy_nazev_bez_mezer"
    "mymod:node",
    -- vlastnosti - mapování (slovník) který definuje vlastnosti a chování
    --              bločku:
    --                  {vlastnost = hodnota,
    --                   vlastnost2 = hodnota2,
    --                   vlastnost3 = hodnota3}
    {
        -- ---< ZÁKLADNÍ VLASTNOSTI >---
        -- description = popis bločku
        description = "Popis bločku",

        -- is_ground_content = je zemní prvek - může být prvek
        --     generován pod zemí
        is_ground_content = true,

        -- groups - skupiny - definuje čím lze objekt vytěžit
        --        crumbly - hlína, písek - lopatou
        --        cracky - kamen - kutáčkem
        --        snappy - listí, drátky, malé rostliny - čímkoliv
        --        choppy - stromy, dřevo - sekera
        --        fleshy - živá zvířata, hráči - meč
        --        explody - výbušniny - ?
        --        oddly_breakable_by_hand - louče - čímkoliv
        groups = {fleshy=2, choppy=1},

        -- inventory_image = obrázek v inventáří
        inventory_image = "mymod_obrazek_do_inventare.png",
        -- tiles = dlaždice - definice jaké obrázky se umístí kam na
        --       náš bloček
        -- tiles = {"mymod_vsechny_strany_stejne.png"},
        tiles = {"mymod_shora.png", "mymod_zdola.png",
                 "mymod_zprava.png", "mymod_zleva.png",
                 "mymod_zezadu.png", "mymod_zepředu.png"},

        -- ---< FUNKCE VOLANÉ PŘI DRŽENÍ BLOČKU >---
        -- on_use = při použití - funkce, která se zavolá když hráč
        --     lehce klikne levým tlačítkem na blok, defaultně se
        --     nestane nic
        on_use = minetest.item_eat(20),  -- hráč získá 20 hit-pointů

        -- on_place = při položení - funkce, která se zavolá, když
        --     hráč klikne pravým tlačítkem na nějaký bloček a drží
        --     u toho náš bloček v ruce, defaultne postaví bloček
        --     pomocí `minetest.item_place()`
        on_place = minetest.item_place,

        -- on_secondary_use = při druhotném použití - funkce, která se
        --     zavolá, když hráč klikne pravým tlačítkem ale neukazuje na
        --     jiný bloček (například ukazuje na nebe či jiný objekt),
        --     defaultně se nic nestane
        on_secondary_use = minetest.item_eat(10),

        -- on_drop = při vyhození - funkce, která se zavolá, pokud hráč
        --     bloček vyhodí (stiskne `Q`), defaultně vyhodí bloček pomocí
        --     `minetest.item_drop`
        on_drop = minetest.item_drop,

        -- after_use = po vykutání - funkce, která se zavolá po vytěžení
        --     bločku. Zpravidla se používá k opotřebení nástrojů, defaultně
        --     dle skupiny bločku
        after_use = nil,

        -- ---< FUNKCE VOLANÉ KDYŽ MÍŘÍME NA BLOČEK VE SVĚTĚ >---
        -- on_construct = při postavení - zavolá se ihned poté, co je bloček
        --     umístěn do světa a je mu předána pouze pozice a nový bloček
        -- Zde pro příklad definujeme vlastní funkci, která nastaví
        -- popis bločku, který se ukáže po ukázání na bloček
        on_construct = function(pozice, blocek)
            local meta = minetest.get_meta(pozice)
            meta:set_string("infotext", "Tohle je blocek")
        end,

        -- after_place_node = po umístění bločku - volá se obdobně jako
        --     on_construct, ale je jí předáno více informací (např. kdo
        --     objekt pokládá, na co se ukazovalo...)
        -- Pro ukázku přiřadíme objekt hráči (pokud jej hráč pokládá,
        --     pokud je pokládá mob či generátor mapy, nic se nestane)
        after_place_node = function(pozice, kdo, zasobnik, kurzor)
           if kdo and kdo:is_player() then
               local meta = minetest.get_meta(pozice)
               meta:set_string("owner", kdo:get_player_name())
           end
        end,

        -- on_punch = při bouchnutí - zavolá se, pokud hráč ukazuje na tento
        --     položený bloček a zároveň v ruce nemá nic, co by definovalo
        --     `on_use` (například nesmí držet jablíčko)
        -- Pro ukázku definujeme funkci, která hráči pošle zprávu, prehraje
        -- zvuk ("sounds/ldoktor_nebouchej.ogg") a zmeni blocek na hlinu
        on_punch = function(pozice, blocek, kdo, kurzor)
           if kdo:is_player() then
               minetest.chat_send_player(kdo:get_player_name(), "Nebouchej me")
               minetest.sound_play("ldoktor_nebouchej")
               minetest.set_node(pozice, { name = "default:dirt" })
           end
        end,
    }
)


-- Definice noveho receptu
-- https://minetest.gitlab.io/minetest/definition-tables/#crafting-recipes
minetest.register_craft(vlastnosti)
minetest.register_craft({
    -- type = typ - druh receptu
    --      shaped - s tvarem
    --      shapeless - bez tvaru
    --      cooking - vaření
    --      fuel - palivo
    type = "shaped",

    -- output = výstup - co bude produktem tohoto receptu, jedná se o text
    --      kde první část je název bločku, pak mezera a nakonec počet bločků
    --      na jednotku vstupu (už víte, proč nesmí být mezera v názvu?)
    output = "mymod:node 32",

    -- recipe = recept - definice receptu. Pro shapeless stačí pole objektů -
    --      recipe = {"default:dirt", "default:dirt", "default:stone"} -
    --      pro shaped se jedná o pole polí:
    --      recipe = {{"A1", "A2", "A3"}, {"B1", "B2", "B3"},
    --                {"C1", "C2", "C3"}}
    --      vyžaduje bločky v "kraftícím stolku"
    --              A1 A2 A3
    --              B1 B2 B3
    --              C1 C2 C3
    recipe = {
        {"default:dirt", "", ""},
        {"default:dirt", "", ""},
        {"default:stone", "default:stone", "default:stone"}
    },
}
