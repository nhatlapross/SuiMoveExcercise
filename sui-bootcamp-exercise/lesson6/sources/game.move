// hoàn thiện code để module có thể publish được
module lesson6::hero_game {
    // Điền thêm các ability phù hợp cho các object
    struct Hero {
        id: UID,
        name: String,
        hp: u64,
        experience: u64,
    }

    // Điền thêm các ability phù hợp cho các object
    struct Sword {
        id: UID,
        attack: u64,
        strenght: u64,
    }

    // Điền thêm các ability phù hợp cho các object
    struct Armor {
        id: UID,
        defense: u64,
    }

    // Điền thêm các ability phù hợp cho các object
    struct Monter {
        id: UID,
        hp: u64,
        strenght: u64,
    }

    struct GameInfo {
        id: UID,
        admin: address
    }

    // hoàn thiện function để khởi tạo 1 game mới
    fun init(ctx: &mut TxContext) {

    }

    // function để create các vật phẩm, nhân vật trong game.
    fun create_hero(name: String, hp: u64, experience:u64, ctx: &mut TxContext): Hero{
        Hero{
            id: object::new(ctx),
            name,
            hp: 100,
            experience: u64,
        }
    }

    fun create_sword(attack: u64, strenght:u64, ctx: &mut TxContext): Sword {
        Sword{
            id: object::new(ctx),
            attack: attack,
            strenght: strenght
        }
    }
    fun create_armor(defense: u64, ctx: &mut TxContext): Armor {
        Armor{
            id: object::new(ctx),
            defense: defense
        }
    }

    // function để create quái vật, chiến đấu với hero, chỉ admin mới có quyền sử dụng function này
    // Gợi ý: khởi tạo thêm 1 object admin.
    fun create_monter(strenght: u64,hp: u64, ctx: &mut TxContext): Monter {
        Monter{
            id: object::new(ctx),
            strenght: strenght,
            hp: hp
        }
    }

    // func để tăng điểm kinh nghiệm cho hero sau khi giết được quái vật
    fun level_up_hero(hero: &mut Hero, amount:u64) {
        hero.hp + amount;
        hero.experience +amount;
    }
    fun level_up_sword(sword: &mut Sword, amount:u64) {
        sword.attack + amount;
        sword.strenght + amount;
    }
    fun level_up_armor(armor: &mut Armor, amount:u64) {
        armor.defense + amount;
    }

    // Tấn công, hoàn thiện function để hero và monter đánh nhau
    // gợi ý: kiểm tra số điểm hp và strength của hero và monter, lấy hp trừ đi số sức mạnh mỗi lần tấn công. HP của ai về 0 trước người đó thua
    public entry fun attack_monter(hero: &mut Hero, monter: &mut Monter) {
        while ( hero.hp > 0 && monter.hp > 0){
            monter.hp = monter.hp - sword.attack;
            hero.hp = hero.hp - monter.strenght + armor.defense;
        }
        if(hero.hp <= 0){
            let Hero { id, name: _, hp: _,  experience: _} = hero;
            object::delete(id);
        }
        if(monter.hp <= 0){
            let Monter { id, strenght: _,  hp: _} = monter;
            object::delete(id);
        }
    }

}
