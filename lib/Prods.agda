{-# OPTIONS --type-in-type --without-K #-}

open import lib.First
open import lib.Paths

module lib.Prods where

  record Unit : Type where
    constructor <> 

  -- sometimes handy not to have definitional η
  data Unit⁺ : Type where
    <>⁺ : Unit⁺

  split1⁺ : (C : Unit⁺ → Type) → C <>⁺ → (x : Unit⁺) → C x
  split1⁺ C b <>⁺ = b

  -- gadget for defeating unused argument check in Agda 2.3.2.1 and later
  -- a version of Unit⁺ that's indexed by an arbitrary thing.  
  data Phantom {A : Type}(a : A) : Type where
      phantom : Phantom a
  
  _×_ : Type -> Type -> Type
  a × b = Σ (\ (_ : a) -> b)

  infixr 10 _×_

  fst≃ : {A : Type} {B : A -> Type} {p q : Σ[ x ∶ A ] B x} -> p ≃ q -> (fst p) ≃ (fst q)
  fst≃ = ap fst
  
  snd≃ : {A : Type} {B : A -> Type} {p q : Σ B} -> (c : p ≃ q) -> (transport B (fst≃ c) (snd p)) ≃ (snd q)
  snd≃ {p = p} {q = .p} id = id

  snd≃' : {A : Type} {B : A -> Type} {p q : Σ B} -> (c : p ≃ q) -> (transport (B o fst) c (snd p)) ≃ (snd q)
  snd≃' α = apd snd α

  pair≃ : {A : Type} {B : A -> Type} {p q : Σ B} -> (α : (fst p) ≃ (fst q)) -> (transport B α (snd p)) ≃ (snd q) -> p ≃ q
  pair≃ {p = x , y} {q = .x , .y} id id = id

  Σ≃η : {A : Type} {B : A -> Type} {p q : Σ B} -> (α : p ≃ q) -> (pair≃ (fst≃ α) (snd≃ α)) ≃ α
  Σ≃η {p = p} {q = .p} id = id

  Σ≃β1 : {A : Type} {B : A -> Type} {p q : Σ B} 
       (α : Path (fst p) (fst q)) 
       (β : Path (transport B α (snd p)) (snd q))
       -> Path (fst≃{B = B} (pair≃ α β)) α
  Σ≃β1 {p = x , y} {q = .x , .y} id id = id

  Σ≃β2 : {A : Type} {B : A -> Type} {p q : Σ B} 
         (α : (fst p) ≃ (fst q))
         (β : (transport B α (snd p)) ≃ (snd q))
      -> (snd≃{B = B} (pair≃ α β)) ≃ 
         (β ∘ (ap (λ x → transport B x (snd p)) (Σ≃β1 {B = B} α β)))
  Σ≃β2 {p = x , y} {q = .x , .y} id id = id

  {-
  -- adjust on the other side
  Σ≃β2' : {A : Type} {B : A -> Type} {p q : Σ B} 
         (α : (fst p) ≃ (fst q))
         (β : (transport B α (snd p)) ≃ (snd q))
      -> {! (snd≃' {B = B} (pair≃ α β))  !} ≃ 
         β 
  Σ≃β2' {p = x , y} {q = .x , .y} id id = id
  -}

  -- subst extension for Γ,x:A⁻ in DTT
  pair≃⁻ : {A : Set} {B : A -> Set} {p q : Σ B} 
        -> (α : (fst p) ≃ (fst q)) -> (snd p) ≃ transport B (! α) (snd q) 
        -> p ≃ q
  pair≃⁻ {A}{B}{p}{q} α β = pair≃ α ((transport-inv-2' B α) ∘ ap (transport B α) β)

  snd≃⁻ : {A : Type} {B : A -> Type} {p q : Σ B} -> (c : p ≃ q) -> (snd p) ≃ transport B (! (fst≃ c)) (snd q)
  snd≃⁻ {p = p} {q = .p} id = id

  ∘-Σ : ∀ {A} {B : A → Type} {p q r : Σ B}
       → (α1 : fst p ≃ fst q) (α2 : fst q ≃ fst r)
       → (β1 : transport B α1 (snd p) ≃ (snd q)) (β2 : transport B α2 (snd q) ≃ (snd r))
       → (pair≃{B = B} α2 β2) ∘ (pair≃ α1 β1) ≃ pair≃ (α2 ∘ α1) (β2 ∘ ap (transport B α2) β1 ∘ ap≃ (transport-∘ B α2 α1))
  ∘-Σ {p = (p1 , p2)} {q = (.p1 , .p2)} {r = (.p1 , .p2)} id id id id = id

  module ΣPath where

    eqv : {A : Type} {B : A → Type} {p q : Σ B}
        → Equiv (Σ \ (α : Path (fst p) (fst q)) → Path (transport B α (snd p)) (snd q))
                (Path p q)
    eqv {B = B} {p = p} {q = q} = 
      improve (hequiv 
        (λ p → pair≃ (fst p) (snd p))
        (λ p → fst≃ p , snd≃ p)
        (λ p' → pair≃ (Σ≃β1 (fst p') (snd p')) 
                      (move-left-right (snd≃ (pair≃{B = B} (fst p') (snd p'))) (snd p')
                         (ap (λ v → transport B v (snd p)) (Σ≃β1 (fst p') (snd p')))
                         (Σ≃β2 {B = B} (fst p') (snd p')) ∘
                       transport-Path-pre' (λ v → transport B v (snd p))
                                           (Σ≃β1 (fst p') (snd p'))
                                           (snd≃ (pair≃{B = B} (fst p') (snd p'))))) 
        (λ p → Σ≃η p))

    path : {A : Type} {B : A → Type} {p q : Σ B}
        →   (Σ \ (α : Path (fst p) (fst q)) → Path (transport B α (snd p)) (snd q))
          ≃ (Path p q)
    path = ua eqv 


  -- tlevel stuff

  Σ-with-Contractible : {A : Type} {B : A → Type}
                        → ( (x : A) → Contractible (B x))
                        -> A ≃ Σ B
  Σ-with-Contractible c = 
     ua (improve (hequiv (λ a → a , fst (c a))
                         fst
                         (λ _ → id)
                         (λ p → pair≃ id (HProp-unique (increment-level (ntype (c (fst p)))) _ _)))) 

  Σ-with-Contractibleβ1 : {A : Type} {B : A → Type}
                        → (c : (x : A) → Contractible (B x))
                        → (coe (Σ-with-Contractible c)) ≃ (\a -> a , fst (c a))
  Σ-with-Contractibleβ1 c = type≃β _

  ΣSubsetPath : {A : Type} {B : A → Type} {p q : Σ B} 
                → ( (x : A) → HProp (B x))
                →   (Path (fst p) (fst q))
                  ≃ (Path p q)
  ΣSubsetPath {p = p}{q = q} hp = ΣPath.path ∘ Σ-with-Contractible (λ p' → use-level{n = -2} (use-level{n = S -2} (hp (fst q)) _ _))

  ΣSubsetPathβ : {A : Type} {B : A → Type} {p q : Σ B} 
               → (hp : (x : A) → HProp (B x)) (p1 : Path (fst p) (fst q))
               → fst≃ (coe (ΣSubsetPath {p = p} {q = q} hp) p1) ≃ p1
  ΣSubsetPathβ {p = (x , _)}  {q = (.x , _)} hp id = 
    ((Σ≃β1 _ _ ∘ ap fst≃ (ap≃ (type≃β ΣPath.eqv))) ∘ 
     ap (fst≃ o coe ΣPath.path) (ap≃ (Σ-with-Contractibleβ1 (λ p' → use-level {n = -2} (use-level {n = S -2} (hp x) _ _))))) ∘
     ap fst≃ (ap≃ (transport-∘ (λ x' → x') ΣPath.path (Σ-with-Contractible (λ p' → use-level {n = -2} (use-level {n = S -2} (hp x) _ _)))))

  postulate --needed for K(G,n)
    ΣSubsetPathβ! : {A : Type} {B : A → Type} {p q : Σ B} 
                  → (hp : (x : A) → HProp (B x)) (p' : Path{Σ B} p q)
                  → (coe (! (ΣSubsetPath {p = p} {q = q} hp)) p') ≃ fst≃ p'

  module Σassoc where

    rassoc : {X : Type} 
             -> {A : X -> Type}
             -> {B : (Σ[ x ∶ X ] (A x)) -> Type}
             -> (Σ[ p ∶ (Σ[ x ∶ X ] (A x)) ] (B p))
             -> Σ[ x  ∶ X ] (Σ[ l1 ∶ A x ] (B (x , l1)))
    rassoc ((fst , snd) , snd') = fst , (snd , snd')
  
    lassoc : {X : Type}
             -> {A : X -> Type}
             -> {B : (Σ[ x ∶ X ] (A x)) -> Type}
             -> Σ[ x ∶ X ] (Σ[ l1 ∶ A x ] (B (x , l1)))
             -> (Σ[ p ∶ (Σ[ x ∶ X ] (A x)) ] (B p))
    lassoc (fst , fst' , snd) = (fst , fst') , snd
  
    eqv : {X : Type}
         -> {A : X -> Type}
         -> {B : (Σ[ x ∶ X ] (A x)) -> Type}
         -> Equiv (Σ[ p ∶ (Σ[ x ∶ X ] (A x)) ] (B p))
                  (Σ[ x  ∶ X ] (Σ[ l1 ∶ A x ] (B (x , l1))))
    eqv = improve (hequiv  rassoc lassoc (λ y → id) (λ x → id))

    path : {X : Type}
         -> {A : X -> Type}
         -> {B : (Σ[ x ∶ X ] (A x)) -> Type}
         ->   (Σ[ p ∶ (Σ[ x ∶ X ] (A x)) ] (B p))
            ≃ (Σ[ x  ∶ X ] (Σ[ l1 ∶ A x ] (B (x , l1))))
    path = ua eqv


  module ΣcommFirstTwo {A : Type} {B : Type} {C : A → B → Type} where
    eqv : Equiv (Σ \ x → Σ \ y → C x y) (Σ \ y → Σ \ x → C x y)
    eqv = improve (hequiv (λ p → fst (snd p) , fst p , snd (snd p)) (λ p → fst (snd p) , fst p , snd (snd p)) (λ _ → id) (λ _ → id))

  Σlevel : ∀ {n} {A : Type} {B : A → Type}
           → NType n A
           → ((x : A) → NType n (B x))
           → NType n (Σ B)
  Σlevel {n = -2} tA tB = transport (NType -2) (Σ-with-Contractible (λ x → use-level (tB x))) tA
  Σlevel {n = S n} tA tB = ntype (λ x y → transport (NType n) ΣPath.path (Σlevel {n = n} (use-level tA _ _) (λ x → use-level (tB (fst y)) _ _)))

  ContractibleEquivUnit : ∀ {A} → Contractible A → Equiv A Unit
  ContractibleEquivUnit c = (improve (hequiv (λ _ → <>) (λ _ → fst c) (λ x → snd c x) (\ _ -> id)))

  Contractible≃Unit : ∀ {A} → Contractible A → A ≃ Unit
  Contractible≃Unit c = ua (ContractibleEquivUnit c)

  abstract
    Contractible-Unit : Contractible Unit
    Contractible-Unit = (<> , \ _ -> id) 
  

  -- transport and ap

  transport-Σ : {Γ : Type} {θ1 θ2 : Γ} (δ : θ1 ≃ θ2)
            (A : Γ -> Type) (B : (γ : Γ) -> A γ -> Type)
            (p : Σ \(x : A θ1) -> B θ1 x)
          -> transport (\ γ -> Σ (B γ)) δ p 
           ≃ (transport A δ (fst p) , 
              transport (λ (γ' : Σ A) → B (fst γ') (snd γ')) 
                    (pair≃ δ id) 
                    (snd p))
  transport-Σ id A B p = id

  transport-com-for-ap-pair :
    {Γ : Type} {θ1 θ2 : Γ} (δ : θ1 ≃ θ2)
    (A : Γ -> Type) (B : (γ : Γ) -> A γ -> Type)
    (p1 : (γ : Γ) -> A γ)
    (p2 : (γ : Γ) -> B γ (p1 γ))
   -> (transport (B θ2) (apd p1 δ)
             (transport (λ γ' → B (fst γ') (snd γ'))
                    (pair≃ {Γ}{A} δ id)
                    (p2 θ1)))
      ≃ 
      (transport (λ z → B z (p1 z)) δ (p2 θ1))
  transport-com-for-ap-pair id _ _ _ _ = id

  ap-pair : {Γ : Type} {θ1 θ2 : Γ} {δ : θ1 ≃ θ2}
              {A : Γ -> Type} {B : (γ : Γ) -> A γ -> Type} 
              {p1 : (γ : Γ) -> A γ} 
              {p2 : (γ : Γ) -> B γ (p1 γ)} 
           -> (apd (\ γ -> (_,_ {A γ} {B γ} (p1 γ) (p2 γ))) δ)
            ≃ pair≃ (apd p1 δ) (apd p2 δ ∘ (transport-com-for-ap-pair δ A B p1 p2))
              ∘ transport-Σ δ A B (p1 θ1 , p2 θ1)
  ap-pair {δ = id} = id

  ap-fst : {Γ : Type} {θ1 θ2 : Γ} {δ : θ1 ≃ θ2}
             {A : Γ -> Type} {B : (γ : Γ) -> A γ -> Type} 
             {p : (γ : Γ) -> Σ (B γ)} 
           -> apd (\ γ -> fst (p γ)) δ
            ≃ fst≃ ((apd p δ) ∘ ! (transport-Σ δ A B (p θ1)))
  ap-fst {δ = id} = id

  transport-com-for-ap-snd : 
             {Γ : Type} {θ1 θ2 : Γ} (δ : θ1 ≃ θ2)
             (A : Γ -> Type) (B : (γ : Γ) -> A γ -> Type)
             (p : (γ : Γ) -> Σ (B γ))
       -> Path (transport (λ z → B z (fst (p z))) δ (snd (p θ1)))
             (transport (B θ2) (fst≃ (apd p δ))
                    (snd (transport (λ z → Σe (A z) (B z)) δ (p θ1))))
  transport-com-for-ap-snd id _ _ _ = id

  ap-snd : {Γ : Type} {θ1 θ2 : Γ} {δ : θ1 ≃ θ2}
             {A : Γ -> Type} {B : (γ : Γ) -> A γ -> Type} 
             {p : (γ : Γ) -> Σ (B γ)} 
           -> apd (\ γ -> snd (p γ)) δ
            ≃ snd≃ (apd p δ) ∘ transport-com-for-ap-snd δ A B p
  ap-snd {δ = id} = id

  -- might want to know what coercing by this does... 
  apΣ : {A A' : Type} {B : A → Type} {B' : A' → Type}
        (a : A ≃ A')
        (b : (\ (x : A) → B x) ≃ (\ (x : A) → B' (coe a x)))
      → Σ B ≃ Σ B'
  apΣ id id = id

  apΣ-l : {A A' : Type} {B : A → Type} {B' : A' → Type}
        (a : A ≃ A')
        (b : (\ (x : A') → B (coe (! a) x)) ≃ B')
      → Σ B ≃ Σ B'
  apΣ-l id id = id
 
  -- build in some β reduction
  apΣ' : {A A' : Type} {B : A → Type} {B' : A' → Type}
         (a : Equiv A A')
         (b : (x' : A') → B (IsEquiv.g (snd a) x') ≃ B' x')
       → Σ B ≃ Σ B'
  apΣ' {A = A} {B = B} {B' = B'}  a b = apΣ (ua a) (λ≃ (λ x' → ap B' (! (ap≃ (type≃β a))) ∘ b (fst a x') ∘ ap B (! (IsEquiv.α (snd a) _)))) -- (λ≃ (λ x → ap B' (! (ap≃ (type≃β a))) ∘ b x))

  ap×-eqv : ∀ {A B A' B'} → Equiv A A' → Equiv B B' → Equiv (A × B) (A' × B')
  ap×-eqv e1 e2 = improve (hequiv (λ p → fst e1 (fst p) , fst e2 (snd p)) (λ p → IsEquiv.g (snd e1) (fst p) , IsEquiv.g (snd e2) (snd p)) 
                                  (λ x → ap2 _,_ (IsEquiv.α (snd e1) _) (IsEquiv.α (snd e2) _))
                                  (λ x → ap2 _,_ (IsEquiv.β (snd e1) _) (IsEquiv.β (snd e2) _)))

  -- non-dependent pairs

  transport-× : {Γ : Type} {θ1 θ2 : Γ} (δ : θ1 ≃ θ2)
          (A : Γ -> Type) (B : (γ : Γ) -> Type)
        -> transport (\ γ -> A γ × B γ) δ 
         ≃ (\ p -> (transport A δ (fst p) , transport B δ (snd p)))
  transport-× id A B = id

  transport-×2 : ∀ {A B} {M N : A} (C : A -> Type) (α : M ≃  N)
                 → transport (\ a -> B × (C a)) α
                 ≃ λ {(b , c) -> (b , (transport C α c))}
  transport-×2 C id = id

  transport-×1 : ∀ {A C} {M N : A} (B : A -> Type) (α : M ≃  N)
                 → transport (\ a -> (B a) × C) α
                 ≃ λ {(b , c) -> (transport B α b , c)}
  transport-×1 C id = id

  snd×≃ : {A B : Type} {p q : A × B} -> p ≃ q -> (snd p) ≃ (snd q)
  snd×≃ {p = p} {q = .p} id = id    

  pair×≃ : {A B : Type} {p q : A × B} -> (fst p) ≃ (fst q) -> (snd p) ≃ (snd q) -> p ≃ q
  pair×≃ a b = ap2 _,_ a b

  ×≃η : {A B : Type} {p q : A × B} -> (α : p ≃ q) -> (pair×≃ (fst≃ α) (snd×≃ α)) ≃ α
  ×≃η {p = p} {q = .p} id = id

  ×≃β1 : {A B : Type} {p q : A × B} 
        (α : Path (fst p) (fst q)) 
        (β : Path (snd p) (snd q))
        -> Path (fst≃{B = \ _ -> B} (pair×≃ α β)) α
  ×≃β1 {p = x , y} {q = .x , .y} id id = id

  ×≃β2 : {A B : Type} {p q : A × B} 
        (α : Path (fst p) (fst q)) 
        (β : Path (snd p) (snd q))
      -> (snd×≃ (pair×≃ α β)) ≃ 
         β
  ×≃β2 {p = x , y} {q = .x , .y} id id = id

  ∘-× : {A : Type} {M N P Q R S : A} (a : N ≃ P) (b : R ≃ S) (c : M ≃ N) (d : Q ≃ R)
      -> pair×≃ a b ∘ pair×≃ c d ≃ pair×≃ (a ∘ c) (b ∘ d)
  ∘-× id id id id = id
  
  ap-×-fst : {A B : Type} {N M : A} -> (f : A -> B) -> (y : B) -> (α : M ≃ N) ->
               ap (λ x → f (x) , y) α ≃ 
               pair×≃ (ap (λ x → f x) α) (ap (λ _ → y) α)
  ap-×-fst _ _ id = id

  ap-×-snd : {A B : Type} {N M : A} -> (f : A -> B) -> (y : B) -> (α : M ≃ N) ->
               ap (λ x → y , f (x)) α ≃
               pair×≃ (ap (λ _ → y) α) (ap (λ x → f (x)) α)
  ap-×-snd _ _ id = id

  pair×≃-id1 : {A B : Type} {a : A} {b b' : B} -> (p : b == b') -> pair×≃ id p == ap (\ x -> a , x) p
  pair×≃-id1 id = id 

  pair×≃-id2 : {A B : Type} {a a' : A} {b : B} -> (p : a == a') -> pair×≃ p id == ap (\ x -> x , b) p
  pair×≃-id2 id = id 

  ap-pair×≃-ap-1 : {A A' B C : Type} (f : A × B → C) (g : A' → A) {a a' : A'} {b b' : B} -> (p : a == a') (q : b == b') -> ap f (pair×≃ (ap g p) q) == ap (λ a'b → f (g (fst a'b) , snd a'b)) (pair×≃ p q)
  ap-pair×≃-ap-1 f g id id = id

  ap-pair×≃-ap-2 : {A B' B C : Type} (f : A × B → C) (g : B' → B) {a a' : A} {b b' : B'} -> (p : a == a') (q : b == b') -> ap f (pair×≃ p (ap g q)) == ap (λ a'b → f ((fst a'b) , g (snd a'b))) (pair×≃ p q)
  ap-pair×≃-ap-2 f g id id = id

  ap-pair×≃-diag : {A C : Type} (f : A × A → C) {a a' : A} (p : a == a') -> ap f (pair×≃ p p) == ap (λ z → f (z , z)) p
  ap-pair×≃-diag f id = id

  fiberwise-to-total : {A : Type} {B B' : A → Type} → (f : (a : A) → B a → B' a) → Σ B → Σ B'
  fiberwise-to-total f (a , b) = (a , f a b)

  -- need to write this one out; would follow from ua and funext
  fiberwise-equiv-to-total : ∀ {A} {B B' : A → Type} → ((x : A) → B x == B' x) → (Σ B) == (Σ B')
  fiberwise-equiv-to-total h = ua (improve (hequiv (fiberwise-to-total (\ x -> coe (h x))) (fiberwise-to-total (λ x → coe (! (h x)))) (λ x → pair≃ id (ap≃ (transport-inv-1 (λ x₁ → x₁) (h (fst x))))) (λ y → pair≃ id (ap≃ (transport-inv-2 (λ x → x) (h (fst y)))))))

  total-space-equiv-to-fiberwise : {A : Type} {B C : A → Type} 
          (f : (x : A) → B x → C x) 
        → IsEquiv (fiberwise-to-total f)
        → (a : A) → IsEquiv (f a)
  total-space-equiv-to-fiberwise {A}{B}{C} f e a = snd (improve (hequiv (f a) 
                                       (λ c → transport B (pres a c) (snd (IsEquiv.g e (a , c))))
                                       (λ x → snd≃ (IsEquiv.α e (a , x)) ∘ ap {M = ap (λ r → fst r) (IsEquiv.β e (a , f a x))}
                                                                             {N = ap (λ r → fst r) (IsEquiv.α e (a , x))}
                                                                             (λ p → transport B p (snd (IsEquiv.g e (a , f a x)))) 
                                               ((! (ap-o fst (fiberwise-to-total f) (IsEquiv.α e (a , x)))) ∘ ap (ap fst) (IsEquiv.γ e (a , x))))
                                       (λ y → snd≃ (IsEquiv.β e (a , y)) ∘ nat (pres a y)) ))  where 
    pres : (a : A) (c : C a) → fst (IsEquiv.g e (a , c)) == a
    pres a c = fst≃ (IsEquiv.β e (a , c))

    nat : ∀ {a} {a'} {b : B a} (p : a == a') → f a' (transport B p b) == transport C p (f a b)
    nat id = id

  -- with η for Σ, you don't need funext
  AC : {A : Type} {B : A → Type} {C : (x : A) → B x → Type} 
     → Equiv ((x : A) → Σ \ y -> C x y)
             (Σ \ (f : (x : A) → B x) → (x : A) → C x (f x))
  AC = improve (hequiv (λ f → (λ x → fst (f x)) , (λ x → snd (f x))) (λ g x → fst g x , snd g x) (λ f → id) (λ y → id))

  swap×fn : ∀ {A B} → (A × B) → (B × A)
  swap×fn (x , y) = (y , x)
    
  swap× : ∀ {A B} → Equiv (A × B) (B × A)
  swap× = equiv swap×fn swap×fn (λ _ → id) (λ _ → id) (λ _ → id)


  singleton-contractible : ∀ {A} {a : A} → NType -2 (Σ \ b → a == b)
  singleton-contractible = ntype ((_ , id) , (λ y → path-induction (λ b p → Path (_ , id) (b , p)) id (snd y)))
