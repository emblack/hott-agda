
-- multicategory with term syntax

open import functorlogic.Lib 

module functorlogic.ModesMultiSyn where

  {-# BUILTIN REWRITE _==_ #-}

  postulate 
    Mode : Set

  postulate 
    _≤ax_ : List Mode -> Mode -> Set 

  mutual
    data _≤_ : List Mode -> Mode -> Set where
      v   : ∀ {p ps} → p ∈ ps → ps ≤ p
      _∘k_ : ∀ {ps qs r} → qs ≤ax r → ps ≤s qs → ps ≤ r

    _≤s_ : List Mode → List Mode → Set
    ps ≤s qs =  All (\ q → ps ≤ q) qs

  _⊆s_ : List Mode → List Mode → Set
  ps ⊆s qs = All (\ q → q ∈ ps) qs

  {-# NO_TERMINATION_CHECK #-}
  -- doesn't catch the mapped recursive call
  ren≤ : ∀ {ps qs : List Mode} {r} → ps ⊆s qs → qs ≤ r → ps ≤ r
  ren≤ θ (v x) = v (lookup θ x)
  ren≤ θ (c ∘k γ) = c ∘k mapAll (ren≤ θ) γ

  r-to-s :  ∀ {ps qs : List Mode} → ps ⊆s qs → ps ≤s qs
  r-to-s r = mapAll v r

  {-# NO_TERMINATION_CHECK #-}
  -- doesn't catch the mapped recursive call
  _∘m_ : ∀ {ps qs : List Mode} {r} → qs ≤ r → ps ≤s qs → ps ≤ r
  (v x) ∘m θ = lookup θ x
  (c ∘k θ1) ∘m θ = c ∘k mapAll (λ x → x ∘m θ) θ1

  _∘s_ : ∀ {ps qs rs : List Mode} → qs ≤s rs → ps ≤s qs → ps ≤s rs
  θ1 ∘s θ2 = mapAll (\ x → x ∘m θ2) θ1

  mutual 
    1ms : ∀ (qs : List Mode) → qs ≤s qs
    1ms [] = <>
    1ms (q :: qs) = v i0 , pm qs
  
    pm : ∀ {q} (qs : List Mode) → (q :: qs) ≤s qs
    pm qs = mapAll (λ e → ren≤ (all-from-in qs iS) e) (1ms qs)

  -- postulate
  --   ·1-unit-l : ∀ {xs y} {α : xs ≤ y} → (1ms _ ·1 α) == α

  postulate
    _⇒_ : ∀ {p q} → (α β : p ≤ q) → Set 
    1⇒ : ∀ {p q} → {α : p ≤ q} → α ⇒ α
    _·2_ : ∀ {x y} {p q r : x ≤ y} → p ⇒ q → q ⇒ r → p ⇒ r

  -- FIXME: congruence and properties

  -- _·1cong_ : ∀ {xs ys z} {p p' : All (_≤_ xs) ys} {q q' : ys ≤ z} → AllAll2 _⇒_ p p' → q ⇒ q' → (p ·1 q) ⇒ (p' ·1 q')
  -- iScong  : {p q : Mode} {ps : List Mode} → {α β : ps ≤ q} → α ⇒ β → iSm {p} α ⇒ iSm β

  1⇒' : ∀ {p q} → {α β : p ≤ q} → α == β -> α ⇒ β
  1⇒' id = 1⇒

  -- -- postulate
  -- --   ·1cong-unit-l : {x z : Mode} {q q' : x ≤ z} (β : q ⇒ q') → (1⇒ {_}{_}{1m} ·1cong β) == β
  -- --   ·1cong-unit-r : {x z : Mode} {q q' : x ≤ z} (β : q ⇒ q') → (β ·1cong 1⇒ {_}{_}{1m} ) == β
  -- --   -- FIXME: doesn't always seem to be working as a rewrite
  -- --   ·1cong-assoc : {x y z w : Mode} {p p' : x ≤ y} {q q' : y ≤ z} {r r' : z ≤ w} {e1 : p ⇒ p'} {e2 : q ⇒ q'} {e3 : r ⇒ r'} 
  -- --                → ((e1 ·1cong e2) ·1cong e3) == (e1 ·1cong (e2 ·1cong e3))
  -- --   ·2-unit-r : {x y : Mode} {p q : x ≤ y} (α : p ⇒ q) → (α ·2 1⇒) == α
  -- --   ·2-unit-l : {x y : Mode} {p q : x ≤ y} (α : p ⇒ q) → (1⇒ ·2 α) == α
  -- --   ·2-assoc  : ∀ {x y : Mode} {α β γ δ : x ≤ y} {e1 : α ⇒ β} {e2 : β ⇒ γ} {e3 : γ ⇒ δ}
  -- --             → ((e1 ·2 e2) ·2 e3) == (e1 ·2 (e2 ·2 e3))
  -- --   interchange : {x y z : Mode} {p1 p2 p3 : x ≤ y} {e1 : p1 ⇒ p2} {e2 : p2 ⇒ p3}
  -- --                 {q1 q2 q3 : y ≤ z} {f1 : q1 ⇒ q2} {f2 : q2 ⇒ q3}
  -- --               → ((e1 ·2 e2) ·1cong (f1 ·2 f2))  == ((e1 ·1cong f1) ·2 (e2 ·1cong f2))
  -- --   -- FIXME: shouldn't this be provable from the others?
  -- --   ·1cong-1⇒ : {x y z : Mode} {p : z ≤ y} {q : y ≤ x} → (1⇒ {_}{_}{p} ·1cong 1⇒ {_}{_}{q}) == 1⇒

  -- -- {-# REWRITE ·1cong-unit-l #-}
  -- -- {-# REWRITE ·1cong-unit-r #-}
  -- -- {-# REWRITE ·2-unit-r #-}
  -- -- {-# REWRITE ·2-unit-l #-}
  -- -- {-# REWRITE ·1cong-1⇒ #-}
  -- -- {-# REWRITE ·2-assoc #-}
  -- -- {-# REWRITE ·1cong-assoc #-}
