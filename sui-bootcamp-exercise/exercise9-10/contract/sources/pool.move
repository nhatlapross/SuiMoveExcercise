/// A flash loan that works for any Coin type
module lesson9::flash_lender {
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    const ELoanTooLarge: u64 = 0;
    const EInvalidRepaymentAmount: u64 = 1;
    const ERepayToWrongLender: u64 = 2;
    const EAdminOnly: u64 = 3;
    const EWithdrawTooLarge: u64 = 4;

    struct FlashLender<phantom T> has key {
        id: UID,
        /// Số lượng coin được phép vay
        to_lend: Balance<T>,
        fee: u64,
    }

    /// Đây là struct không có key và store, nên nó sẽ không được transfer và không được lưu trữ bền vững. và nó cũng không có drop nên cách duy nhất để xoá nó làm gọi hàm repay.
    /// Đây là cái chúng ta muốn cho một gói vay.
    struct Receipt<phantom T> {
        flash_lender_id: ID,
        repay_amount: u64
    }

    /// Một đối tượng truyền đạt đặc quyền rút tiền và gửi tiền vào
    /// trường hợp của `FlashLender` có ID `flash_lender_id`. Ban đầu được cấp cho người tạo của `FlashLender`
    /// và chỉ tồn tại một `AdminCap` duy nhất cho mỗi nhà cho vay.
    struct AdminCap has key, store {
        id: UID,
        flash_lender_id: ID,
    }

    // === Creating a flash lender ===

    /// Tạo một đối tượng `FlashLender` chia sẻ làm cho `to_lend` có sẵn để vay
    /// Bất kỳ người vay nào sẽ cần trả lại số tiền đã vay và `fee` trước khi kết thúc giao dịch hiện tại.
    public fun new<T>(to_lend: Balance<T>, fee: u64, ctx: &mut TxContext): AdminCap {
        let id = object::new(ctx);
        let flash_lender_id = object::uid_to_inner(&id);
        let flash_lender = FlashLender { id, to_lend, fee };
        transfer::share_object(flash_lender);
        AdminCap { id: object::new(ctx), flash_lender_id }
    }

    /// Giống như `new`, nhưng chuyển `AdminCap` cho người gửi giao dịch
    public entry fun create<T>(to_lend: Coin<T>, fee: u64, ctx: &mut TxContext) {
        let balance = coin::into_balance(to_lend);
        let admin_cap = new(balance, fee, ctx);
        transfer::public_transfer(admin_cap, tx_context::sender(ctx))
    }

   /// Yêu cầu một khoản vay với `amount` từ `lender`. `Receipt<T>`
   /// đảm bảo rằng người vay sẽ gọi `repay(lender, ...)` sau này trong giao dịch này.
   /// Hủy bỏ nếu `amount` lớn hơn số tiền mà `lender` có sẵn để cho vay.
    public fun loan<T>(
        self: &mut FlashLender<T>, amount: u64, ctx: &mut TxContext
    ): (Coin<T>, Receipt<T>) {
        let to_lend = &mut self.to_lend;
        assert!(balance::value(to_lend) >= amount, ELoanTooLarge);
        let loan = coin::take(to_lend, amount, ctx);
        let repay_amount = amount + self.fee;
        let receipt = Receipt { flash_lender_id: object::id(self), repay_amount };

        (loan, receipt)
    }

   /// Trả lại khoản vay được ghi lại bởi `receipt` cho `lender` với `payment`.
   /// Hủy bỏ nếu số tiền trả lại không chính xác hoặc `lender` không phải là `FlashLender` đã cấp khoản vay ban đầu.
    public fun repay<T>(self: &mut FlashLender<T>, payment: Coin<T>, receipt: Receipt<T>) {
        let Receipt { flash_lender_id, repay_amount } = receipt;
        assert!(object::id(self) == flash_lender_id, ERepayToWrongLender);
        assert!(coin::value(&payment) == repay_amount, EInvalidRepaymentAmount);

        coin::put(&mut self.to_lend, payment)
    }

    /// Cho phép quản trị viên của `self` rút tiền.
    public fun withdraw<T>(self: &mut FlashLender<T>, admin_cap: &AdminCap, amount: u64, ctx: &mut TxContext): Coin<T> {
        check_admin(self, admin_cap);

        let to_lend = &mut self.to_lend;
        assert!(balance::value(to_lend) >= amount, EWithdrawTooLarge);
        coin::take(to_lend, amount, ctx)
    }

    public entry fun deposit<T>(self: &mut FlashLender<T>, admin_cap: &AdminCap, coin: Coin<T>) {
        // Chỉ có chủ sở hữu của `AdminCap` cho `self` mới có thể gửi tiền vào.
        check_admin(self, admin_cap);
        coin::put(&mut self.to_lend, coin);
    }

    /// Cho phép quản trị viên cập nhật phí cho `self`.
    public entry fun update_fee<T>(self: &mut FlashLender<T>, admin_cap: &AdminCap, new_fee: u64) {
        check_admin(self, admin_cap);

        self.fee = new_fee
    }

    fun check_admin<T>(self: &FlashLender<T>, admin_cap: &AdminCap) {
        assert!(object::borrow_id(self) == &admin_cap.flash_lender_id, EAdminOnly);
    }


    /// Return the current fee for `self`
    public fun fee<T>(self: &FlashLender<T>): u64 {
        self.fee
    }

    /// Trả về số tiền tối đa có sẵn để mượn.
    public fun max_loan<T>(self: &FlashLender<T>): u64 {
        balance::value(&self.to_lend)
    }

    /// Trả về số tiền mà người giữ `self` phải trả lại.
    public fun repay_amount<T>(self: &Receipt<T>): u64 {
        self.repay_amount
    }

    /// Trả về số tiền mà người giữ `self` phải trả lại.
    public fun flash_lender_id<T>(self: &Receipt<T>): ID {
        self.flash_lender_id
    }
}
