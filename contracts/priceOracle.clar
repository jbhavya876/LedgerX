;; RWA PRICE ORACLE CONTRACT
;; Connects tokenized properties with external price feeds and market data

(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-oracle-not-found (err u101))
(define-constant err-invalid-price (err u102))
(define-constant err-stale-data (err u103))
(define-constant err-oracle-not-active (err u104))
(define-constant err-insufficient-stake (err u105))

;; Oracle Configuration
(define-map oracle-registry
  principal  ;; oracle-address
  {
    is-active: bool,
    stake-amount: uint,
    successful-updates: uint,
    failed-updates: uint,
    reputation-score: uint,
    specialization: (string-ascii 32),
    geographic-focus: (string-ascii 64),
    last-update: uint,
    created-at: uint
  })

;; External Price Feeds
(define-map price-feeds
  { property-id: (string-ascii 64), oracle: principal, feed-type: (string-ascii 16) }
  {
    price: uint,
    confidence: uint,
    timestamp: uint,
    data-source: (string-ascii 64),
    update-frequency: uint,
    validity-period: uint,
    metadata: (string-ascii 256)
  })

;; Aggregated Price Data
(define-map aggregated-prices
  (string-ascii 64)  ;; property-id
  {
    consensus-price: uint,
    price-deviation: uint,
    number-of-feeds: uint,
    confidence-score: uint,
    last-updated: uint,
    update-trigger: (string-ascii 32)
  })

;; Market Data Integration
(define-map market-indicators
  { indicator-type: (string-ascii 32), region: (string-ascii 32) }
  {
    value: uint,
    change-24h: int,
    change-7d: int,
    data-source: (string-ascii 64),
    last-updated: uint,
    reliability-score: uint
  })

;; Property Valuation History
(define-map valuation-history
  { property-id: (string-ascii 64), valuation-index: uint }
  {
    valuation-price: uint,
    valuation-method: (string-ascii 32),
    oracle-address: principal,
    confidence-level: uint,
    supporting-data: (string-ascii 256),
    timestamp: uint
  })

(define-map valuation-history-count (string-ascii 64) uint)

;; Oracle Staking & Reputation System
(define-map oracle-stakes
  principal
  {
    staked-amount: uint,
    staked-at: uint,
    locked-until: uint,
    slash-count: uint,
    reward-balance: uint
  })

;; AGGREGATE PROPERTY PRICE (MOVED BEFORE PUBLIC FUNCTIONS)
(define-private (aggregate-property-price (property-id (string-ascii 64)))
  (begin
    ;; Store placeholder aggregated data
    (map-set aggregated-prices property-id {
      consensus-price: u0,
      price-deviation: u0,
      number-of-feeds: u0,
      confidence-score: u0,
      last-updated: stacks-block-height,
      update-trigger: "oracle-submit"
    })
    
    (ok true)))

;; UPDATE ORACLE REPUTATION (MOVED BEFORE PUBLIC FUNCTIONS)
(define-private (update-oracle-reputation (oracle-address principal))
  (let ((oracle-info (unwrap! (map-get? oracle-registry oracle-address) err-oracle-not-found))
        (successful (get successful-updates oracle-info))
        (failed (get failed-updates oracle-info))
        (total-updates (+ successful failed)))
    
    (let ((success-rate (if (> total-updates u0) 
                          (/ (* successful u10000) total-updates) 
                          u5000))
          (consistency-bonus (if (> successful u10) u500 u0))
          (penalty (if (> failed u5) (* failed u100) u0)))
      
      (let ((new-reputation (if (> (+ success-rate consistency-bonus) penalty)
                              (- (+ success-rate consistency-bonus) penalty)
                              u0)))
        ;; Update oracle reputation
        (map-set oracle-registry oracle-address
          (merge oracle-info { reputation-score: new-reputation }))
        (ok new-reputation)))))

;; REGISTER NEW ORACLE
(define-public (register-oracle
    (oracle-address principal)
    (stake-amount uint)
    (specialization (string-ascii 32))
    (geographic-focus (string-ascii 64)))
  (let ((minimum-stake u1000000)) ;; 1,000 STX minimum stake
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (asserts! (>= stake-amount minimum-stake) err-insufficient-stake)
    
    ;; Register oracle
    (map-set oracle-registry oracle-address {
      is-active: true,
      stake-amount: stake-amount,
      successful-updates: u0,
      failed-updates: u0,
      reputation-score: u5000,
      specialization: specialization,
      geographic-focus: geographic-focus,
      last-update: stacks-block-height,
      created-at: stacks-block-height
    })
    
    ;; Record stake
    (map-set oracle-stakes oracle-address {
      staked-amount: stake-amount,
      staked-at: stacks-block-height,
      locked-until: (+ stacks-block-height u4320),
      slash-count: u0,
      reward-balance: u0
    })
    
    (ok oracle-address)))

;; SUBMIT PRICE FEED
(define-public (submit-price-feed
    (property-id (string-ascii 64))
    (price uint)
    (confidence uint)
    (data-source (string-ascii 64))
    (feed-type (string-ascii 16))
    (metadata (string-ascii 256)))
  (let ((oracle-info (unwrap! (map-get? oracle-registry tx-sender) err-oracle-not-found)))
    ;; Validate oracle is active and authorized
    (asserts! (get is-active oracle-info) err-oracle-not-active)
    (asserts! (> price u0) err-invalid-price)
    (asserts! (<= confidence u10000) err-invalid-price)
    
    ;; Store price feed
    (map-set price-feeds 
      { property-id: property-id, oracle: tx-sender, feed-type: feed-type } 
      {
        price: price,
        confidence: confidence,
        timestamp: stacks-block-height,
        data-source: data-source,
        update-frequency: u144,
        validity-period: u1008,
        metadata: metadata
      })
    
    ;; Update oracle reputation
    (map-set oracle-registry tx-sender
      (merge oracle-info { 
        successful-updates: (+ (get successful-updates oracle-info) u1),
        last-update: stacks-block-height
      }))
    
    ;; Trigger price aggregation
    (unwrap-panic (aggregate-property-price property-id))
    (ok true)))

;; UPDATE MARKET INDICATORS
(define-public (update-market-indicator
    (indicator-type (string-ascii 32))
    (region (string-ascii 32))
    (value uint)
    (change-24h int)
    (change-7d int)
    (data-source (string-ascii 64)))
  (let ((oracle-info (unwrap! (map-get? oracle-registry tx-sender) err-oracle-not-found)))
    (asserts! (get is-active oracle-info) err-oracle-not-active)
    
    ;; Store market indicator
    (map-set market-indicators 
      { indicator-type: indicator-type, region: region }
      {
        value: value,
        change-24h: change-24h,
        change-7d: change-7d,
        data-source: data-source,
        last-updated: stacks-block-height,
        reliability-score: (get reputation-score oracle-info)
      })
    
    (ok true)))

;; SUBMIT PROPERTY VALUATION
(define-public (submit-property-valuation
    (property-id (string-ascii 64))
    (valuation-price uint)
    (valuation-method (string-ascii 32))
    (confidence-level uint)
    (supporting-data (string-ascii 256)))
  (let ((oracle-info (unwrap! (map-get? oracle-registry tx-sender) err-oracle-not-found))
        (valuation-count (default-to u0 (map-get? valuation-history-count property-id))))
    
    (asserts! (get is-active oracle-info) err-oracle-not-active)
    (asserts! (> valuation-price u0) err-invalid-price)
    
    ;; Store valuation
    (map-set valuation-history 
      { property-id: property-id, valuation-index: valuation-count }
      {
        valuation-price: valuation-price,
        valuation-method: valuation-method,
        oracle-address: tx-sender,
        confidence-level: confidence-level,
        supporting-data: supporting-data,
        timestamp: stacks-block-height
      })
    
    ;; Update valuation count
    (map-set valuation-history-count property-id (+ valuation-count u1))
    
    ;; Update aggregated price based on formal valuation
    (unwrap-panic (aggregate-property-price property-id))
    
    (ok valuation-count)))

;; READ-ONLY FUNCTIONS

(define-read-only (get-oracle-info (oracle-address principal))
  (map-get? oracle-registry oracle-address))

(define-read-only (get-price-feed 
    (property-id (string-ascii 64)) 
    (oracle principal) 
    (feed-type (string-ascii 16)))
  (map-get? price-feeds { property-id: property-id, oracle: oracle, feed-type: feed-type }))

(define-read-only (get-aggregated-price (property-id (string-ascii 64)))
  (map-get? aggregated-prices property-id))

(define-read-only (get-market-indicator 
    (indicator-type (string-ascii 32)) 
    (region (string-ascii 32)))
  (map-get? market-indicators { indicator-type: indicator-type, region: region }))

(define-read-only (get-latest-valuation (property-id (string-ascii 64)))
  (let ((valuation-count (default-to u0 (map-get? valuation-history-count property-id))))
    (if (> valuation-count u0)
      (map-get? valuation-history 
        { property-id: property-id, valuation-index: (- valuation-count u1) })
      none)))

(define-read-only (get-valuation-at-index 
    (property-id (string-ascii 64)) 
    (index uint))
  (map-get? valuation-history { property-id: property-id, valuation-index: index }))

(define-read-only (is-price-stale 
    (property-id (string-ascii 64)) 
    (oracle principal) 
    (feed-type (string-ascii 16)))
  (match (get-price-feed property-id oracle feed-type)
    feed-data 
      (let ((data-age (- stacks-block-height (get timestamp feed-data)))
            (validity-period (get validity-period feed-data)))
        (> data-age validity-period))
    true))

(define-read-only (get-price-confidence 
    (property-id (string-ascii 64)))
  (match (get-aggregated-price property-id)
    price-data (some (get confidence-score price-data))
    none))

;; ORACLE MANAGEMENT FUNCTIONS

(define-public (deactivate-oracle (oracle-address principal))
  (let ((oracle-info (unwrap! (map-get? oracle-registry oracle-address) err-oracle-not-found)))
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (map-set oracle-registry oracle-address
      (merge oracle-info { is-active: false }))
    (ok true)))

(define-public (slash-oracle 
    (oracle-address principal) 
    (slash-amount uint) 
    (reason (string-ascii 128)))
  (let ((oracle-info (unwrap! (map-get? oracle-registry oracle-address) err-oracle-not-found))
        (stake-info (unwrap! (map-get? oracle-stakes oracle-address) err-oracle-not-found)))
    
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    
    ;; Increase failed updates count
    (map-set oracle-registry oracle-address
      (merge oracle-info { 
        failed-updates: (+ (get failed-updates oracle-info) u1)
      }))
    
    ;; Slash stake
    (map-set oracle-stakes oracle-address
      (merge stake-info {
        staked-amount: (if (> (get staked-amount stake-info) slash-amount)
                         (- (get staked-amount stake-info) slash-amount)
                         u0),
        slash-count: (+ (get slash-count stake-info) u1)
      }))
    
    ;; Update reputation
    (unwrap-panic (update-oracle-reputation oracle-address))
    
    (ok true)))

;; EMERGENCY FUNCTIONS

(define-public (pause-oracle-system)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (ok true)))

(define-public (emergency-price-update 
    (property-id (string-ascii 64)) 
    (emergency-price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (asserts! (> emergency-price u0) err-invalid-price)
    
    ;; Set emergency price with high confidence
    (map-set aggregated-prices property-id {
      consensus-price: emergency-price,
      price-deviation: u0,
      number-of-feeds: u1,
      confidence-score: u10000,
      last-updated: stacks-block-height,
      update-trigger: "emergency"
    })
    
    (ok true)))
