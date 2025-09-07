;; ----------------------------------------
;; Voting DAO Contract (Skeleton)
;; ----------------------------------------

;; ---------- Data Variables ----------
(define-data-var proposal-counter uint u0)

;; ---------- Data Maps ----------
(define-map proposals
  {id: uint}
  {
    title: (string-ascii 100),
    description: (string-ascii 250),
    creator: principal,
    for-votes: uint,
    against-votes: uint,
    start-block: uint,
    end-block: uint,
    executed: bool
  }
)

(define-map votes
  {proposal-id: uint, voter: principal}
  {choice: bool})

;; ---------- Public Functions ----------

;; Create a new proposal
(define-public (create-proposal (title (string-ascii 100)) (description (string-ascii 250)) (duration uint))
  (let 
    (
      (proposal-id (var-get proposal-counter))
      (start-height burn-block-height)
      (end-height (+ burn-block-height duration))
    )
    (asserts! (and 
      (> end-height start-height)
      (> (len title) u0)
      (> (len description) u0)) 
      (err u4))
    (ok (begin
      (map-insert proposals 
        {id: proposal-id}
        {
          title: title,
          description: description,
          creator: tx-sender,
          for-votes: u0,
          against-votes: u0,
          start-block: start-height,
          end-block: end-height,
          executed: false
        })
      (var-set proposal-counter (+ proposal-id u1))
      proposal-id))
  ))

;; Helper functions for vote validation
(define-private (check-not-voted (proposal-id uint))
  (match (map-get? votes {proposal-id: proposal-id, voter: tx-sender})
         prev-vote
         (err u2)
         (ok true)))

(define-private (check-in-voting-period (proposal {title: (string-ascii 100), description: (string-ascii 250), creator: principal, for-votes: uint, against-votes: uint, start-block: uint, end-block: uint, executed: bool}))
  (if (and 
       (>= burn-block-height (get start-block proposal))
       (<= burn-block-height (get end-block proposal)))
    (ok true)
    (err u3)))

;; Cast a vote on a proposal
(define-public (vote (proposal-id uint) (support bool))
  (begin
    (asserts! (>= proposal-id u0) (err u5))
    (let
      ((proposal (unwrap! (map-get? proposals {id: proposal-id}) (err u1))))
      
      (try! (check-not-voted proposal-id))
      (try! (check-in-voting-period proposal))
      
      (map-set votes 
        {proposal-id: proposal-id, voter: tx-sender}
        {choice: support})
      
      (map-set proposals
        {id: proposal-id}
        (merge proposal 
          {
            for-votes: (if support 
              (+ (get for-votes proposal) u1)
              (get for-votes proposal)),
            against-votes: (if (not support)
              (+ (get against-votes proposal) u1)
              (get against-votes proposal))
          }
        ))
      
      (ok true)
    )))

;; Execute proposal (if passed)
(define-public (execute-proposal (proposal-id uint))
  (ok true) ;; TODO: implement execution logic
)

;; ---------- Read-Only Functions ----------

;; Get details of a proposal
(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals {id: proposal-id})
)

;; Get result of a proposal
(define-read-only (get-result (proposal-id uint))
  (match (map-get? proposals {id: proposal-id})
         proposal
         (ok {
           for-votes: (get for-votes proposal),
           against-votes: (get against-votes proposal),
           is-active: (and 
             (>= burn-block-height (get start-block proposal))
             (<= burn-block-height (get end-block proposal))
           )
         })
         (err u1)))

;; Check if a user has voted
(define-read-only (has-voted (proposal-id uint) (voter principal))
  (is-some (map-get? votes {proposal-id: proposal-id, voter: voter}))
)
