;; PROPERTY TOKENIZER CONTRACT
;; Revolutionary tokenized real estate with dynamic pricing!

(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-property-not-found (err u101))
(define-constant err-invalid-token-count (err u102))
(define-constant err-insufficient-payment (err u103))
(define-constant err-token-not-available (err u104))

;; PROPERTY REGISTRY
(define-map properties
  (string-ascii 64) ;; property-id
  {
    property-address: (string-ascii 256),
    total-value: uint, ;; Total property value in cents
    total-tokens: uint, ;; Number of tokens (e.g., 100)
    price-per-token: uint, ;; Current price per token in cents
    tokens-sold: uint, ;; Number of tokens sold
    created-at: uint, ;; Block height when created
    is-active: bool,
    owner: principal ;; Property owner
  })

;; TOKEN OWNERSHIP REGISTRY
(define-map token-ownership
  { property-id: (string-ascii 64), token-index: uint }
  {
    owner: principal,
    purchase-price: uint, ;; Price paid when purchased
    purchase-block: uint, ;; When purchased
    is-for-sale: bool,
    asking-price: (optional uint)
  })

;; PRICE HISTORY FOR TREND ANALYSIS
(define-map price-history
  { property-id: (string-ascii 64), price-index: uint }
  {
    price: uint,
    timestamp: uint,
    transaction-type: (string-ascii 10), ;; "buy", "sell", "initial"
    volume: uint ;; Number of tokens in transaction
  })

(define-map price-history-count (string-ascii 64) uint)

;; CURRENT MARKET TRENDS
(define-map market-trends
  (string-ascii 64) ;; property-id
  {
    trend-direction: (string-ascii 10), ;; "rising", "falling", "stable"
    price-change-24h: int, ;; Price change in last 24h (can be negative)
    volume-24h: uint, ;; Trading volume in last 24h
    last-updated: uint
  })

;; CREATE NEW TOKENIZED PROPERTY
(define-public (create-tokenized-property
    (property-id (string-ascii 64))
    (property-address (string-ascii 256))
    (total-value uint)
    (total-tokens uint))
  (let ((price-per-token (/ total-value total-tokens)))
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (asserts! (> total-tokens u0) err-invalid-token-count)
    (asserts! (> total-value u0) err-invalid-token-count)

    ;; Register the property
    (map-set properties property-id {
      property-address: property-address,
      total-value: total-value,
      total-tokens: total-tokens,
      price-per-token: price-per-token,
      tokens-sold: u0,
      created-at: stacks-block-height,
      is-active: true,
      owner: tx-sender
    })

    ;; Initialize price history
    (map-set price-history { property-id: property-id, price-index: u0 } {
      price: price-per-token,
      timestamp: stacks-block-height,
      transaction-type: "initial",
      volume: u0
    })
    (map-set price-history-count property-id u1)

    ;; Initialize market trend
    (map-set market-trends property-id {
      trend-direction: "stable",
      price-change-24h: 0,
      volume-24h: u0,
      last-updated: stacks-block-height
    })

    (ok property-id)))

;; BUY TOKEN (NFT) - REVOLUTIONARY PRICING MECHANISM!
(define-public (buy-token
    (property-id (string-ascii 64))
    (token-index uint)
    (payment-amount uint))
  (let ((property-info (unwrap! (map-get? properties property-id) err-property-not-found))
        (current-price (get price-per-token property-info))
        (existing-owner (map-get? token-ownership { property-id: property-id, token-index: token-index })))

    ;; Validate purchase
    (asserts! (get is-active property-info) err-property-not-found)
    (asserts! (< token-index (get total-tokens property-info)) err-invalid-token-count)
    (asserts! (>= payment-amount current-price) err-insufficient-payment)

    (asserts! (is-none existing-owner) err-token-not-available) ;; Token must be unowned

    ;; Record token ownership
    (map-set token-ownership { property-id: property-id, token-index: token-index } {
      owner: tx-sender,
      purchase-price: payment-amount,
      purchase-block: stacks-block-height,
      is-for-sale: false,
      asking-price: none
    })

    ;; DYNAMIC PRICE UPDATE - THE MAGIC HAPPENS HERE!
    (if (> payment-amount current-price)
      (begin
        ;; Update price for ALL tokens of this property
        (map-set properties property-id
          (merge property-info {
            price-per-token: payment-amount,
            tokens-sold: (+ (get tokens-sold property-info) u1)
          }))

        ;; Record price history
        (let ((history-count (default-to u0 (map-get? price-history-count property-id))))
          (map-set price-history { property-id: property-id, price-index: history-count } {
            price: payment-amount,
            timestamp: stacks-block-height,
            transaction-type: "buy",
            volume: u1
          })
          (map-set price-history-count property-id (+ history-count u1)))

        ;; Update market trend
        (unwrap-panic (update-market-trend property-id payment-amount current-price u1)))

      (begin
        ;; If buying at current price, just update tokens sold
        (map-set properties property-id
          (merge property-info {
            tokens-sold: (+ (get tokens-sold property-info) u1)
          }))))

    (ok true)))

;; SELL TOKEN - WITH PRICE IMPACT
(define-public (sell-token
    (property-id (string-ascii 64))
    (token-index uint)
    (asking-price uint)
    (buyer principal))
  (let ((property-info (unwrap! (map-get? properties property-id) err-property-not-found))
        (token-info (unwrap! (map-get? token-ownership { property-id: property-id, token-index: token-index }) err-token-not-available))
        (current-price (get price-per-token property-info)))

    ;; Validate seller
    (asserts! (is-eq tx-sender (get owner token-info)) err-unauthorized)
    (asserts! (> asking-price u0) err-insufficient-payment)

    ;; Transfer ownership
    (map-set token-ownership { property-id: property-id, token-index: token-index } {
      owner: buyer,
      purchase-price: asking-price,
      purchase-block: stacks-block-height,
      is-for-sale: false,
      asking-price: none
    })

    ;; DYNAMIC PRICE IMPACT
    (if (not (is-eq asking-price current-price))
      (begin
        ;; Update property price based on sale
        (map-set properties property-id
          (merge property-info { price-per-token: asking-price }))

        ;; Record transaction in price history
        (let ((history-count (default-to u0 (map-get? price-history-count property-id))))
          (map-set price-history { property-id: property-id, price-index: history-count } {
            price: asking-price,
            timestamp: stacks-block-height,
            transaction-type: "sell",
            volume: u1
          })
          (map-set price-history-count property-id (+ history-count u1)))

        ;; Update trend analysis
        (unwrap-panic (update-market-trend property-id asking-price current-price u1)))

      ;; No price change, just record volume
      (unwrap-panic (update-market-trend property-id current-price current-price u1)))

    (ok true)))

;; UPDATE MARKET TREND ANALYSIS
(define-private (update-market-trend
    (property-id (string-ascii 64))
    (new-price uint)
    (old-price uint)
    (volume uint))
  (let ((current-trend (default-to
          { trend-direction: "stable", price-change-24h: 0, volume-24h: u0, last-updated: u0 }
          (map-get? market-trends property-id)))
        (price-change (- (to-int new-price) (to-int old-price))))

    (map-set market-trends property-id {
      trend-direction: (if (> new-price old-price)
                         "rising"
                         (if (< new-price old-price) "falling" "stable")),
      price-change-24h: price-change,
      volume-24h: (+ (get volume-24h current-trend) volume),
      last-updated: stacks-block-height
    })
    (ok true)))

;; READ FUNCTIONS - GET DATA FROM BLOCKCHAIN

(define-read-only (get-property-info (property-id (string-ascii 64)))
  (map-get? properties property-id))

(define-read-only (get-token-owner (property-id (string-ascii 64)) (token-index uint))
  (map-get? token-ownership { property-id: property-id, token-index: token-index }))

(define-read-only (get-current-price (property-id (string-ascii 64)))
  (match (map-get? properties property-id)
    property-data (some (get price-per-token property-data))
    none))

(define-read-only (get-price-history
    (property-id (string-ascii 64))
    (start-index uint)
    (count uint))
  (let ((total-count (default-to u0 (map-get? price-history-count property-id))))
    (if (< start-index total-count)
      ;; NOTE: This is a simplified read-only function for demonstration. 
      ;; A production version would need a more robust way to return a list of structs.
      (ok (list 
        (map-get? price-history { property-id: property-id, price-index: start-index })
        (map-get? price-history { property-id: property-id, price-index: (+ start-index u1) })
      ))
      (err u404))))

(define-read-only (get-market-trend (property-id (string-ascii 64)))
  (map-get? market-trends property-id))

;; CALCULATE PROPERTY STATISTICS
(define-read-only (get-property-stats (property-id (string-ascii 64)))
  (match (map-get? properties property-id)
    property-data
      (let ((market-cap (* (get price-per-token property-data) (get total-tokens property-data)))
            (tokens-remaining (- (get total-tokens property-data) (get tokens-sold property-data))))
        (ok {
          market-cap: market-cap,
          tokens-remaining: tokens-remaining,
          ownership-percentage: (/ (* (get tokens-sold property-data) u100) (get total-tokens property-data)),
          current-price: (get price-per-token property-data)
        }))
    (err u404)))

;; GET USER'S TOKEN PORTFOLIO
(define-read-only (get-user-tokens (user principal) (property-id (string-ascii 64)))
  (let ((property-info (unwrap! (map-get? properties property-id) (err u404))))
    ;; This is a simplified version - in production, you'd implement a more efficient query
    (ok "User token query - implement iteration logic")))

;; ADMIN FUNCTIONS
(define-public (pause-property (property-id (string-ascii 64)))
  (let ((property-info (unwrap! (map-get? properties property-id) err-property-not-found)))
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (map-set properties property-id (merge property-info { is-active: false }))
    (ok true)))

(define-public (resume-property (property-id (string-ascii 64)))
  (let ((property-info (unwrap! (map-get? properties property-id) err-property-not-found)))
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (map-set properties property-id (merge property-info { is-active: true }))
    (ok true)))
