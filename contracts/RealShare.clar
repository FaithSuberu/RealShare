;; Tokenized Real-World Asset Fractional Ownership Contract
;; Implements SIP-010 Fungible Token Standard with dividends distribution



;; Contract admin - can mint/burn tokens and deposit dividends
(define-constant admin tx-sender)

;; Token details
(define-constant token-name "RealWorldAsset Shares")
(define-constant token-symbol u"RWA")
(define-constant token-decimals u6)

;; Total supply of shares
(define-data-var total-supply uint u0)

;; Mapping from user principal to token balance
(define-map balances principal uint)

;; Dividends per share, scaled by 1,000,000 for precision
(define-data-var dividends-per-share uint u0)

;; Mapping from user principal to dividends-per-share value at last withdrawal
(define-map withdrawn-dividends principal uint)

;;;;;;;;;;;;;;;;;;;;;;;
;; Fungible Token Logic
;;;;;;;;;;;;;;;;;;;;;;;

(define-public (get-name)
  (ok token-name)
)

(define-public (get-symbol)
  (ok token-symbol)
)

(define-public (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-read-only (get-balance (owner principal))
  (ok (default-to u0 (map-get? balances owner)))
)

(define-private (mint (recipient principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender admin) (err u100)) ;; only admin can mint
    (let ((current-balance (default-to u0 (map-get? balances recipient))))
      (map-set balances recipient (+ current-balance amount))
      (var-set total-supply (+ (var-get total-supply) amount))
      (ok true)
    )
  )
)

(define-private (burn (from principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender admin) (err u101)) ;; only admin can burn
    (let ((current-balance (default-to u0 (map-get? balances from))))
      (asserts! (>= current-balance amount) (err u102))
      (map-set balances from (- current-balance amount))
      (var-set total-supply (- (var-get total-supply) amount))
      (ok true)
    )
  )
)

(define-public (transfer (recipient principal) (amount uint))
  (let ((sender-balance (default-to u0 (map-get? balances tx-sender))))
    (asserts! (>= sender-balance amount) (err u103))
    (map-set balances tx-sender (- sender-balance amount))
    (map-set balances recipient (+ (default-to u0 (map-get? balances recipient)) amount))
    (ok true)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dividend Distribution & Claim
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Admin deposits dividends (in micro-STX) to be distributed among token holders
(define-public (deposit-dividends (amount uint))
  (begin
    (asserts! (is-eq tx-sender admin) (err u104))
    (let (
      (current-dps (var-get dividends-per-share))
      (supply (var-get total-supply))
      (increment (if (is-eq supply u0) u0 (/ (* amount u1000000) supply)))
    )
      (var-set dividends-per-share (+ current-dps increment))
      ;; NOTE: Actual STX transfer to this contract must be done off-chain
      (ok true)
    )
  )
)

;; Users claim their pending dividends proportional to their token balance
(define-public (claim-dividends)
  (let (
    (balance (default-to u0 (map-get? balances tx-sender)))
    (current-dps (var-get dividends-per-share))
    (last-dps (default-to u0 (map-get? withdrawn-dividends tx-sender)))
    (owed (/ (* balance (- current-dps last-dps)) u1000000))
  )
    (asserts! (> owed u0) (err u105))
    (map-set withdrawn-dividends tx-sender current-dps)
    ;; NOTE: Actual STX payout must be handled off-chain or via SIP-010 transfer
    (ok owed)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Admin mint & burn wrappers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (admin-mint (recipient principal) (amount uint))
  (mint recipient amount)
)

(define-public (admin-burn (from principal) (amount uint))
  (burn from amount)
)
