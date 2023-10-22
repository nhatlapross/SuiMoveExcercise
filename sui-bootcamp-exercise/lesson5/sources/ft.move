// Hoàn thiện đoạn code để có thể publish được
module lesson5::FT_TOKEN {
    use sui::coin::{Self, CoinMetadata, TreasuryCap, Coin};
    use std::option;
    use sui::url;
    use sui::tx_context::{Self,TxContext};
    use sui::transfer;
    use std::string;
    use sui::event;

    struct FT_TOKEN has drop{ 

    }

    struct EventTransferToken has copy, drop {
        success: bool,
        amount: u64,
        recipient: address
    }

    fun init(witness: FT_TOKEN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency(
            witness,
            2,
            b"ALVIN",
            b"ALVIN TOKEN",
            b"This token for test only",
            option::some(url::new_unsafe_from_bytes(b"http://fb.com/nhatlapross")),
            ctx
        );
    }

    // hoàn thiện function để có thể tạo ra 10_000 token cho mỗi lần mint, và mỗi owner của token mới có quyền mint
    public entry fun mint(_ &CoinMetadata<FT_TOKEN>,treasury_cap: &mut TreasuryCap<FT_TOKEN>, ctx: &mut TxContext) {
        coin::mint(treasury_cap, 10000, ctx);
    }

    // Hoàn thiện function sau để user hoặc ai cũng có quyền tự đốt đi số token đang sở hữu
    public entry fun burn_token(treasury_cap: &mut TreasuryCap<FT_TOKEN>, coin: Coin<FT_TOKEN>) {
        coin::burn(treasury_cap,coin);
    }

    // Hoàn thiện function để chuyển token từ người này sang người khác.
    public entry fun transfer_token(coin:CoinMetadata<FT_TOKEN>, recipient:address) {
        // sau đó khởi 1 Event, dùng để tạo 1 sự kiện khi function transfer được thực thi
        transfer::public_transfer(coin,recipient);
        event::emit(EventTransferToken{
            success: true,
            amount: amount,
            recipient:recipient
        });
    }

    // Hoàn thiện function để chia Token Object thành một object khác dùng cho việc transfer
    // gợi ý sử dụng coin:: framework
    public entry fun split_token(coin: Coin<FT_TOKEN>, split_amount: u64, ctx: &mut TxContext) {
        coin::split(coin, split_amount, ctx);
    }

    // Viết thêm function để token có thể update thông tin sau
    public entry fun update_name(cap: &coin::TreasuryCap<FT_TOKEN>, coin: &mut coin::CoinMetadata<FT_TOKEN>, name: string::String) {
        coin::update_name(cap,coin,name);
        event::emit(UpdateEvent{
            success: true,
            data:  b"Name updated"
        });
    }

    public entry fun update_description(cap: &coin::TreasuryCap<FT_TOKEN>, coin: &mut coin::CoinMetadata<FT_TOKEN>, description: string::String) {
        coin::update_description(cap,coin,description);
        event::emit(UpdateEvent{
            success: true,
            data:  b"Description updated"
        });
    }

    public entry fun update_symbol(cap: &coin::TreasuryCap<FT_TOKEN>, coin: &mut coin::CoinMetadata<FT_TOKEN>, symbol: ascii::String) {
        coin::update_symbol(cap,coin,symbol);
        event::emit(UpdateEvent{
            success: true,
            data:  b"symbol updated"
        });
    }

    public entry fun update_icon_url(cap: &coin::TreasuryCap<FT_TOKEN>, coin: &mut coin::CoinMetadata<FT_TOKEN>, url: ascii::String) {
        coin::update_icon_url(cap,coin,description);
        event::emit(UpdateEvent{
            success: true,
            data:  b"Icon url updated"
        });
    }

    // sử dụng struct này để tạo event cho các function update bên trên.
    struct UpdateEvent {
        success: bool,
        data: String
    }

    // Viết các function để get dữ liệu từ token về để hiển thị
    public entry fun get_token_name(coin: &coin::CoinMetadata<FT_TOKEN>) {
        coin::get_name(coin);
    }
    public entry fun get_token_description(coin: &coin::CoinMetadata<FT_TOKEN>) {
        coin::get_description(coin);
    }
    public entry fun get_token_symbol(coin: &coin::CoinMetadata<FT_TOKEN>) {
        coin::get_symbol(coin);
    }
    public entry fun get_token_icon_url(coin: &coin::CoinMetadata<FT_TOKEN>) {
        coin::get_icon_url(coin);
    }
}
