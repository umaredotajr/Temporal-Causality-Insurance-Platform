;; Timeline Alteration Coverage Contract

(define-map policies
  { id: uint }
  {
    owner: principal,
    timeline-id: uint,
    coverage-amount: uint,
    premium: uint,
    expiration: uint,
    active: bool
  }
)

(define-data-var next-policy-id uint u0)

(define-public (purchase-policy (timeline-id uint) (coverage-amount uint) (premium uint) (duration uint))
  (let
    ((new-id (var-get next-policy-id))
     (expiration (+ block-height duration)))
    (var-set next-policy-id (+ new-id u1))
    (ok (map-set policies
      { id: new-id }
      {
        owner: tx-sender,
        timeline-id: timeline-id,
        coverage-amount: coverage-amount,
        premium: premium,
        expiration: expiration,
        active: true
      }
    ))
  )
)

(define-public (cancel-policy (policy-id uint))
  (match (map-get? policies { id: policy-id })
    policy
      (begin
        (asserts! (is-eq tx-sender (get owner policy)) (err u403))
        (ok (map-set policies
          { id: policy-id }
          (merge policy { active: false })
        )))
    (err u404)
  )
)

(define-read-only (get-policy (policy-id uint))
  (map-get? policies { id: policy-id })
)

(define-read-only (is-policy-active (policy-id uint))
  (match (map-get? policies { id: policy-id })
    policy (and (get active policy) (< block-height (get expiration policy)))
    false
  )
)
