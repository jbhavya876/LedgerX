;; RWA PROPERTY NFT TOKENS CONTRACT
;; Each token represents fractional ownership of real estate property!


(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-not-found (err u101))
(define-constant err-wrong-owner (err u102))
(define-constant err-already-exists (err u103))

;; NFT TOKEN DEFINITION
(define-non-fungible-token property-token 
  { property-id: (string-ascii 64), token-index: uint })

;; TOKEN METADATA STORAGE
(define-map token-metadata
  { property-id: (string-ascii 64), token-index: uint }
  {
    property-address: (string-ascii 256),
    token-name: (string-ascii 64),        ;; e.g., "NYC Condo Unit #23"
    token-description: (string-ascii 512), ;; Property details
    image-url: (optional (string-ascii 256)), ;; Property image
    ownership-percentage: uint,           ;; Percentage of property owned
    minted-at: uint,                     ;; Block height when minted
    total-tokens-in-property: uint       ;; Total tokens for this property
  })

;; TOKEN COUNTER FOR EACH PROPERTY
(define-map property-token-count (string-ascii 64) uint)

;; TOKEN TRADING HISTORY
(define-map token-trading-history
  { property-id: (string-ascii 64), token-index: uint, trade-index: uint }
  {
    from-owner: (optional principal),
    to-owner: principal,
    trade-price: uint,
    trade-timestamp: uint,
    trade-type: (string-ascii 10)  ;; "mint", "buy", "sell", "transfer"
  })

(define-map token-trade-count 
  { property-id: (string-ascii 64), token-index: uint } 
  uint)

;; HELPER FUNCTION TO MINT A SINGLE TOKEN
(define-private (mint-single-token 
    (property-id (string-ascii 64))
    (property-address (string-ascii 256))
    (token-index uint)
    (recipient principal)
    (ownership-per-token uint)
    (total-tokens uint))
  (let ((token-id { property-id: property-id, token-index: token-index }))
    ;; Mint individual NFT token
    (try! (nft-mint? property-token token-id recipient))
    
    ;; Set token metadata
    (map-set token-metadata token-id {
      property-address: property-address,
      token-name: "Property Token",
      token-description: "Fractional ownership token representing property share.",
      image-url: none,
      ownership-percentage: ownership-per-token,
      minted-at: stacks-block-height,
      total-tokens-in-property: total-tokens
    })
    
    ;; Record minting in trading history
    (map-set token-trading-history 
      { property-id: property-id, token-index: token-index, trade-index: u0 } {
      from-owner: none,
      to-owner: recipient,
      trade-price: u0,
      trade-timestamp: stacks-block-height,
      trade-type: "mint"
    })
    (map-set token-trade-count { property-id: property-id, token-index: token-index } u1)
    
    (ok true)))

;; ITERATIVE MINTING HELPER FOR FOLD
(define-private (mint-token-helper
    (index uint)
    (inputs {
      property-id: (string-ascii 64),
      property-address: (string-ascii 256),
      recipient: principal,
      ownership-per-token: uint,
      total-tokens: uint,
      current-index: uint
    }))
  (begin
    ;; Only mint if we haven't exceeded our token count
    (if (< (get current-index inputs) (get total-tokens inputs))
      (begin
        ;; Mint the token (ignore errors for fold compatibility)
        (match (mint-single-token
          (get property-id inputs)
          (get property-address inputs)
          (get current-index inputs)
          (get recipient inputs)
          (get ownership-per-token inputs)
          (get total-tokens inputs))
          success-result
            ;; Return inputs with incremented index
            (merge inputs { current-index: (+ (get current-index inputs) u1) })
          error-result
            ;; Return inputs unchanged on error
            inputs)
      )
      ;; Return inputs unchanged if we've reached the limit
      inputs)))

;; MINT NEW PROPERTY TOKENS (SIMPLIFIED APPROACH)
(define-public (mint-property-tokens
    (property-id (string-ascii 64))
    (property-address (string-ascii 256))
    (token-count uint)
    (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (asserts! (> token-count u0) err-not-found)
    (asserts! (<= token-count u5) err-not-found) ;; Limited to 5 tokens per batch for simplicity
    
    (let ((ownership-per-token (/ u10000 token-count)))
      ;; Mint tokens individually
      (if (>= token-count u1) (try! (mint-single-token property-id property-address u0 recipient ownership-per-token token-count)) true)
      (if (>= token-count u2) (try! (mint-single-token property-id property-address u1 recipient ownership-per-token token-count)) true)
      (if (>= token-count u3) (try! (mint-single-token property-id property-address u2 recipient ownership-per-token token-count)) true)
      (if (>= token-count u4) (try! (mint-single-token property-id property-address u3 recipient ownership-per-token token-count)) true)
      (if (>= token-count u5) (try! (mint-single-token property-id property-address u4 recipient ownership-per-token token-count)) true)
      
      ;; Set total token count for property
      (map-set property-token-count property-id token-count)
      
      (ok token-count))))

;; TRANSFER TOKEN OWNERSHIP
(define-public (transfer
    (token-id { property-id: (string-ascii 64), token-index: uint })
    (sender principal)
    (recipient principal))
  (let ((current-owner (nft-get-owner? property-token token-id)))
    (asserts! (is-eq (some sender) current-owner) err-wrong-owner)
    (asserts! (is-eq tx-sender sender) err-unauthorized)
    
    ;; Execute NFT transfer
    (try! (nft-transfer? property-token token-id sender recipient))
    
    ;; Record transfer in trading history
    (let ((trade-count (default-to u0 
                         (map-get? token-trade-count 
                           { property-id: (get property-id token-id), 
                             token-index: (get token-index token-id) }))))
      (map-set token-trading-history 
        { property-id: (get property-id token-id), 
          token-index: (get token-index token-id), 
          trade-index: trade-count } {
        from-owner: (some sender),
        to-owner: recipient,
        trade-price: u0, ;; Transfer has no price
        trade-timestamp: stacks-block-height,
        trade-type: "transfer"
      })
      (map-set token-trade-count 
        { property-id: (get property-id token-id), token-index: (get token-index token-id) } 
        (+ trade-count u1)))
    
    (ok true)))

;; RECORD PURCHASE TRANSACTION (Called by main contract)
(define-public (record-purchase
    (token-id { property-id: (string-ascii 64), token-index: uint })
    (buyer principal)
    (seller (optional principal))
    (price uint))
  (let ((trade-count (default-to u0 
                       (map-get? token-trade-count 
                         { property-id: (get property-id token-id), 
                           token-index: (get token-index token-id) }))))
    
    ;; Only property tokenizer contract can call this
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    
    ;; Record the purchase
    (map-set token-trading-history 
      { property-id: (get property-id token-id), 
        token-index: (get token-index token-id), 
        trade-index: trade-count } {
      from-owner: seller,
      to-owner: buyer,
      trade-price: price,
      trade-timestamp: stacks-block-height,
      trade-type: "buy"
    })
    
    (map-set token-trade-count 
      { property-id: (get property-id token-id), token-index: (get token-index token-id) } 
      (+ trade-count u1))
    
    (ok true)))

;; READ FUNCTIONS - NFT TRAIT IMPLEMENTATION

(define-read-only (get-last-token-id)
  (ok u0)) ;; Simplified for this implementation

(define-read-only (get-token-uri (token-id { property-id: (string-ascii 64), token-index: uint }))
  (let ((metadata (map-get? token-metadata token-id)))
    (match metadata
      token-data (ok (some (concat "https://api.rwa-oracle.com/metadata/" 
                                 (get property-id token-id))))
      (ok none))))

(define-read-only (get-owner (token-id { property-id: (string-ascii 64), token-index: uint }))
  (ok (nft-get-owner? property-token token-id)))

;; ENHANCED READ FUNCTIONS

(define-read-only (get-token-metadata (token-id { property-id: (string-ascii 64), token-index: uint }))
  (map-get? token-metadata token-id))

(define-read-only (get-property-total-tokens (property-id (string-ascii 64)))
  (map-get? property-token-count property-id))

(define-read-only (get-token-trading-history 
    (token-id { property-id: (string-ascii 64), token-index: uint })
    (start-index uint)
    (count uint))
  (let ((total-trades (default-to u0 (map-get? token-trade-count token-id))))
    (if (< start-index total-trades)
      (ok (list 
        (map-get? token-trading-history { property-id: (get property-id token-id), token-index: (get token-index token-id), trade-index: start-index })
        (map-get? token-trading-history { property-id: (get property-id token-id), token-index: (get token-index token-id), trade-index: (+ start-index u1) })))
      (err u404))))

;; TOKEN PORTFOLIO FUNCTIONS

(define-read-only (get-user-token-count (user principal) (property-id (string-ascii 64)))
  ;; Count how many tokens of this property the user owns
  ;; This would require iteration in a real implementation
  (let ((total-tokens (default-to u0 (map-get? property-token-count property-id))))
    (ok u0))) ;; Placeholder - implement proper counting

;; TOKEN ANALYTICS

(define-read-only (get-token-value-history 
    (token-id { property-id: (string-ascii 64), token-index: uint }))
  ;; Get price history for this specific token
  (let ((trade-count (default-to u0 (map-get? token-trade-count token-id))))
    (ok {
      total-trades: trade-count,
      last-trade-price: u0,  ;; Get from latest trade
      appreciation: u0       ;; Calculate price appreciation
    })))

;; UPDATE TOKEN METADATA (Admin only)
(define-public (update-token-image
    (token-id { property-id: (string-ascii 64), token-index: uint })
    (image-url (string-ascii 256)))
  (let ((existing-metadata (unwrap! (map-get? token-metadata token-id) err-not-found)))
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    
    (map-set token-metadata token-id 
      (merge existing-metadata { image-url: (some image-url) }))
    (ok true)))

(define-public (update-token-description
    (token-id { property-id: (string-ascii 64), token-index: uint })
    (description (string-ascii 512)))
  (let ((existing-metadata (unwrap! (map-get? token-metadata token-id) err-not-found)))
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    
    (map-set token-metadata token-id 
      (merge existing-metadata { token-description: description }))
    (ok true)))
