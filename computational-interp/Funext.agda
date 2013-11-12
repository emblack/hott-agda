{-# OPTIONS --without-K --type-in-type #-}

open import lib.Prelude

module computational-interp.Funext where

  Paths' : Type → Type
  Paths' A = Σ \ (p : A × A) → fst p == snd p

  contract-Paths'-eqv : ∀ {A} → Equiv (Paths' A) A
  contract-Paths'-eqv {A} = (improve (hequiv (\ {((x , y) , p) -> x})
                                        (λ x → (x , x) , id)
                                        α (λ _ → id) )) where
                  α : (x : Paths' A) → ((fst (fst x) , fst (fst x)) , id) == x
                  α ((x , y) , p) = path-induction (λ y₁ p₁ → ((x , x) , id) == ((x , y₁) , p₁)) id p

  contract-Paths' : ∀ {A} → (Paths' A) == A
  contract-Paths' = ua contract-Paths'-eqv 

  module FunExt where

    eqv : ∀ {A B} → Paths' (A → B) == (A → Paths' B)
    eqv {A} {B} = ! (ap (λ y → A → y) (contract-Paths' {B})) ∘ (contract-Paths' {A → B})

    eqv-id : ∀ {A B} (f : A → B) → coe eqv ((f , f) , id) == (λ x → ((f x) , (f x)) , id)
    eqv-id {A}{B} f =
                coe (! (ap (λ y → A → y) (contract-Paths' {B})) ∘ (contract-Paths' {A → B})) ((f , f) , id) ≃〈 ap (λ h → coe (h ∘ contract-Paths' {A → B}) ((f , f) , id)) (! (ap-! (λ y → A → y) (contract-Paths' {B}))) 〉
                coe ((ap (λ y → A → y) (! (contract-Paths' {B}))) ∘ (contract-Paths' {A → B})) ((f , f) , id) ≃〈 ap≃ (transport-∘ (λ x → x) (ap (λ y → A → y) (! (contract-Paths' {B}))) (contract-Paths' {A → B})) 〉
                (coe (ap (λ y → A → y) (! (contract-Paths' {B}))) o coe (contract-Paths' {A → B})) ((f , f) , id) ≃〈 id 〉
                (coe (ap (λ y → A → y) (! (contract-Paths' {B}))) (coe (contract-Paths' {A → B}) ((f , f) , id))) ≃〈 ap (λ z → coe (ap (λ y → A → y) (! (contract-Paths' {B}))) z) (ap≃ (type≃β contract-Paths'-eqv)) 〉
                (coe (ap (λ y → A → y) (! (contract-Paths' {B}))) f) ≃〈 ap≃ (! (transport-ap-assoc' (λ x → x) (λ y → A → y) (! contract-Paths'))) 〉
                (transport (λ y → A → y) (! (contract-Paths' {B})) f) ≃〈 transport-→-post (! contract-Paths') f 〉
                (\ g -> coe (! (contract-Paths' {B})) o g) f ≃〈 id 〉 
                (coe (! (contract-Paths' {B})) o f) ≃〈 ap (λ x → x o f) (type≃β! contract-Paths'-eqv) 〉 
                (λ x → ((f x) , (f x)) , id) ∎ 

    left : ∀ {A B} → (A → Paths' B) → A → B
    left f x = (fst (fst (f x)))

    right : ∀ {A B} → (A → Paths' B) → A → B
    right f x = (snd (fst (f x)))

    like-fst : ∀ {A B} → (A → Paths' B) → (A → B) × (A → B)
    like-fst f = (left f , right f)

    forward : ∀ {A B} → (α : Paths' (A → B)) 
            → (like-fst (coe eqv α)) == fst α
    forward {A}{B} ((f , .f) , id) = ap2 _,_ (ap left (eqv-id f)) (ap right (eqv-id f))

    hfiber-fst : ∀ {A} {B : A → Type} (a : A) → B a == HFiber {A = Σ B} fst a
    hfiber-fst {B = B} a = ua (improve (hequiv (λ b → (a , b) , id) (λ p₁ → transport B (snd p₁) (snd (fst p₁))) (λ _ → id) (λ {((a1 , b) , p) → path-induction-l (λ a2 p₁ → (b₁ : B a2) → Id ((a , transport B p₁ b₁) , id) ((a2 , b₁) , p₁)) (λ _ → id) p b})))

    laststep : ∀ {A B} (f g : A → B) → Equiv (Σ (λ (p₁ : A → Paths' B) → like-fst p₁ == (f , g))) ((x : A) → f x == g x)
    laststep {A}{B} f g = improve (hequiv (λ z → transport (λ (fg : (A → B) × (A → B)) → (x : A) → (fst fg) x == (snd fg) x) (snd z) (λ x → snd (fst z x)))
                                          (λ h → (λ x → (f x , g x) , h x) , id)
                                          α (λ y → id)) where 
             α : {fg : (A → B) × (A → B)} → (x : (Σ (λ (p₁ : A → Paths' B) → like-fst p₁ == fg))) → 
                 ((λ x₁ → (fst fg x₁ , snd fg x₁) , transport (λ fg' → (x₂ : A) → fst fg' x₂ == snd fg' x₂) (snd x) (λ x₂ → snd (fst x x₂)) x₁) , id) == x
             α {fg} (h , α) = path-induction
                                (λ fg₁ α₁ →
                                   ((λ x₁ →
                                       (fst fg₁ x₁ , snd fg₁ x₁) ,
                                       transport (λ fg' → (x₂ : A) → Id (fst fg' x₂) (snd fg' x₂)) α₁
                                       (λ x₂ → snd (h x₂)) x₁)
                                    , id)
                                   == (h , α₁))
                                id α

    fiberwise-to-total : {A : Type} {B B' : A → Type} → (f : (a : A) → B a → B' a) → Σ B → Σ B'
    fiberwise-to-total f (a , b) = (a , f a b)

    -- need to write this one out; would follow from ua and funext
    fiberwise-equiv-to-total : ∀ {A} {B B' : A → Type} → ((x : A) → B x == B' x) → (Σ B) == (Σ B')
    fiberwise-equiv-to-total h = ua (improve (hequiv (fiberwise-to-total (\ x -> coe (h x))) (fiberwise-to-total (λ x → coe (! (h x)))) (λ x → pair≃ id (ap≃ (transport-inv-1 (λ x₁ → x₁) (h (fst x))))) (λ y → pair≃ id (ap≃ (transport-inv-2 (λ x → x) (h (fst y)))))))

    funext : {A B : Type} (f g : A → B) → (f == g) == ((x : A) → f x == g x)
    funext {A}{B} f g = f == g ≃〈 hfiber-fst {B = λ fg → fst fg == snd fg} (f , g) 〉 
                        Σ (λ (p₁ : Paths' (A → B)) → fst p₁ == (f , g)) ≃〈 apΣ-l eqv id 〉 
                        Σ (λ (p₁ : A → Paths' B) → fst (coe (! eqv) p₁) == (f , g)) ≃〈 fiberwise-equiv-to-total (λ p1 → ua (pre∘-equiv (forward (coe (! eqv) p1) ∘ ! (ap like-fst (ap≃ (transport-inv-2 (λ x → x) eqv)))))) 〉 
                        Σ (λ (p₁ : A → Paths' B) → (left p₁ , right p₁) == (f , g)) ≃〈 ua (laststep f g) 〉 
                        (((x : A) → f x == g x) ∎)


  module Coprod (A : Type) (B : Type) where

    eqv : Paths' (Either A B) == Either (Paths' A) (Paths' B)
    eqv = ap2 Either (! (contract-Paths' {A})) (! (contract-Paths' {B}))  ∘ (contract-Paths' {Either A B})

    C : (x y : Either A B) → Type
    C (Inl a) (Inl a') = a == a'
    C (Inr b) (Inr b') = b == b'
    C _ _ = Void

    step : (a : A) → coe (! eqv) (Inl ((a , a) , id)) == ((Inl a , Inl a) , id)
    step = {!!}

    e' : (p : Either A B × Either A B) → Equiv (Σ \ (q : Paths' (Either A B)) → fst q == p) (C (fst p) (snd p))
    e' p = improve (hequiv l {!!} {!!} {!!}) where
      l : (Σ \ (q : Paths' (Either A B)) → fst q == p) → _
      l = {!!}

    e : (p : Either A B × Either A B) → Equiv (Σ \ (q : Either (Paths' A) (Paths' B)) → fst (coe (! eqv) q) == p) (C (fst p) (snd p)) 
    e p = improve (hequiv l (r p) {!!} {!!}) where
      l : Σ (λ q → fst (coe (! eqv) q) == p) -> _
      l (Inl ((x , .x) , id) , eq) = path-induction (λ p₁ eq₁ → C (fst p₁) (snd p₁)) (transport (λ x₁ → C (fst (fst x₁)) (snd (fst x₁))) (! (step x)) id) eq
      l (Inr ((y , .y) , id) , eq) = {!!}

      r : (p : Either A B × Either A B) → (C (fst p) (snd p)) -> (Σ \ (q : Either (Paths' A) (Paths' B)) → fst (coe (! eqv) q) == p)
      r (Inl x , Inl y) c = (Inl ((x , y) , c)) , {!!}
      r (Inl x , Inr y) ()
      r (Inr x , Inl y) c = {!!}
      r (Inr x , Inr y) c = {!!}

    -- seems like you could do it, but would the fact that eqv is an equivalence help at all?

{-
    another attempt

    C : (a a' : A) → Either (Paths' A) (Paths' B) → Type
    C a a' (Inl ((a1 , a1'), p)) = (a == a1) × (a' == a1')
    C a a' (Inr _) = Void 

    coprod2 : (a a' : A) (p : Paths' (Either A B)) → C a a' (coe eqv p) == (fst p == (Inl a , Inl a'))
    coprod2 a a' ((Inl x , .(Inl x)) , id) = {!!}
    coprod2 a a' ((Inr x , .(Inr x)) , id) = {!!}

    coprod3 : (a a' : A) (p : Either (Paths' A) (Paths' B)) → C a a' p == (fst (coe (! eqv) p) == (Inl a , Inl a'))
    coprod3 a a' (Inl ((x , .x) , id)) = (a == x) × (a' == x) ≃〈 {!!} 〉
                                         Path {(Either A B × Either A B)} (Inl x , Inl x) (Inl a , Inl a') ≃〈 {!!} 〉 
                                         (fst (coe (! eqv) (Inl ((x , x) , id))) == (Inl a , Inl a') ∎)
    coprod3 a a' (Inr ((x , .x) , id)) = {!!}

    fiberwise-eqv : {A : Type} {B B' : A → Type} → (f : (a : A) → B a → B' a)
                  → IsEquiv {(Σ B)} {(Σ B')} (fiberwise-to-total f) 
                  → (a : A) → B a == B' a
    fiberwise-eqv f (isequiv g α β _) a = ua (improve (hequiv (f a) (λ b' → coe {!!} (snd (g (a , b')))) {!!} {!!}))

    movearg : ∀ {A B} → Equiv (A → Paths' B) (Σ (λ (p₁ : (A → B) × (A → B)) → (x : A) → fst p₁ x == snd p₁ x)) 
    movearg = improve (hequiv ((λ f →
                                      ((\ x -> fst (fst (f x))) , (λ x₁ → snd (fst (f x₁)))) ,
                                      (λ x₁ → snd (f x₁))))
                               (λ x x₁ → ((fst (fst x) x₁) , (snd (fst x) x₁)) , (snd x x₁))
                               (λ _ → id) (λ _ → id))

    funext : {A B : Type} (f g : A → B) → (f == g) == ((x : A) → f x == g x)
    funext {A} {B} f g = fiberwise-eqv {A = (A → B) × (A → B)} {B = \ p → fst p == snd p} {B' = \ p → (x : A) → fst p x == snd p x}
                                       (λ {(f , g) → λ p₁ x → ap≃ p₁ {x}})
                                       STS
                                       (f , g) where
        tot : (Paths' (A → B)) → Σ (λ (p₁ : (A → B) × (A → B)) → (x : A) → fst p₁ x == snd p₁ x)
        tot = fiberwise-to-total {A = (A → B) × (A → B)} {B = \ p → fst p == snd p} {B' = \ p → (x : A) → fst p x == snd p x} (λ {(f , g) → λ p₁ x → ap≃ p₁ {x}})

        e : Equiv (Paths' (A → B)) (Σ (λ (p₁ : (A → B) × (A → B)) → (x : A) → fst p₁ x == snd p₁ x))
        e = movearg ∘equiv coe-equiv eqv

        STS : IsEquiv {Paths' (A → B)} {Σ (λ (p₁ : (A → B) × (A → B)) → (x : A) → fst p₁ x == snd p₁ x)} 
                      tot
        STS = transport IsEquiv (fst e ≃〈 {!!} 〉 
                                 fst movearg o coe eqv ≃〈 {!!} 〉 
                                 fst movearg o coe (! (ap (\ y -> A → y) (contract-Paths' {B}))) o coe (contract-Paths' {A → B}) ≃〈 {!!} 〉 
                                 fst movearg o coe (ap (\ y -> A → y) (! (contract-Paths' {B}))) o coe (contract-Paths' {A → B}) ≃〈 {!!} 〉 
                                 fst movearg o (\ z -> coe (! (contract-Paths' {B})) o z) o coe (contract-Paths' {A → B}) ≃〈 {!!} 〉 
                                 ((λ f →
                                      ((\ x -> fst (fst (f x))) , (λ x₁ → snd (fst (f x₁)))) ,
                                      (λ x₁ → snd (f x₁)))) o (\ z -> coe (! (contract-Paths' {B})) o z) o coe (contract-Paths' {A → B}) ≃〈 {!!} 〉 
                                 (\ p -> fst p , λ x → ap≃ (snd p) {x}) ≃〈 {!!} 〉 
                                 tot ∎)
                                (snd e) 
-}
