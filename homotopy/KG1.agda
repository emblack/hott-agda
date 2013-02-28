
{-# OPTIONS --type-in-type --without-K #-}

open import lib.Prelude
open Truncation
open Int
open import homotopy.HStructure
open LoopSpace

module homotopy.KG1 where

  -- reflection of G
  module K (G : Group) where
   private
    module K' where
     open Group G
     
     private
       data KG1' : Type where
         base' : KG1'
       
     KG1 : Type
     KG1 = KG1'
     
     base : KG1 
     base = base'
     
     postulate 
       level  : NType (tl 1) KG1
       loop       : El -> Path base base
       loop-ident : loop ident  ≃ id
       loop-comp  : ∀ g1 g2 → loop (comp g1 g2) ≃ (loop g2) ∘ (loop g1)
     
     KG1-rec : ∀ {C} 
             -> (nC : NType (tl 1) C)
             -> (b' : C)
             -> (l' : GroupHom G (PathGroup (C , nC) b'))
             -> KG1 → C
     KG1-rec _ b' _ base' = b'
     
     KG1-elim : (C : KG1 → NTypes (tl 1))
             -> (b' : fst (C base))
             -> (loop' : (x : El) → transport (fst o C) (loop x) b' ≃ b')
             -> (preserves-ident : (x : El) → Path{Path{fst (C base)} _ _}
                                               (transport (λ p → transport (fst o C) p b' ≃ b') loop-ident
                                                         (loop' ident))
                                               (id {_} {b'}))
             -> (preserves-comp  : (g1 g2 : El) → transport (λ p → transport (fst o C) p b' ≃ b') (loop-comp g1 g2) (loop' (comp g1 g2))
                                                   ≃ {! (loop' g1) !})
             -> (x : KG1) → fst (C x)
     KG1-elim _ b' _ _ _ base' = b'
   open K' public
   
   open Group G

   loop-inv : ∀ g -> loop (inv g) ≃ ! (loop g)
   loop-inv g = cancels-is-inverse ((loop-ident ∘ ap loop (invr g)) ∘ ! (loop-comp g (inv g)))
    


  module H-on-KG1 (A : AbelianGroup) where
    open Group (fst A)
    module KG1 = K (fst A)
    open KG1 using (KG1 ; KG1-rec ; KG1-elim)

    abstract
      trivial1 : ∀ {A} (nA : NType (tl 1) A)
               -> { x y : A} {p q : x ≃ y} {r s : p ≃ q} -> r ≃ s
      trivial1 nA = HSet-UIP (use-level {tl 1} nA _ _) _ _ _ _

    mult-loop : (g : El) (x : KG1) → x ≃ x
    mult-loop g = (KG1-elim (λ x → x ≃ x , path-preserves-level KG1.level)
                            (KG1.loop g)
                            loop'
                            (λ _ → trivial1 KG1.level)
                            (λ _ _ → trivial1 KG1.level)) where
      abstract
              loop' : (g' : El) → transport (λ x' → x' ≃ x') (KG1.loop g') (KG1.loop g) ≃ KG1.loop g
              loop' g' = transport (λ x → Id x x) (KG1.loop g') (KG1.loop g) ≃〈 transport-Path (λ x → x) (λ x → x) (KG1.loop g') (KG1.loop g) 〉
                         ap (λ x → x) (KG1.loop g') ∘ KG1.loop g ∘ ! (ap (λ x → x) (KG1.loop g')) ≃〈 ap (λ y → y ∘ KG1.loop g ∘ ! y) (ap-id (KG1.loop g')) 〉 
                         (KG1.loop g') ∘ KG1.loop g ∘ ! (KG1.loop g') ≃〈 ap (λ x → KG1.loop g' ∘ KG1.loop g ∘ x) (! (KG1.loop-inv g')) 〉 
                         (KG1.loop g') ∘ KG1.loop g ∘ (KG1.loop (inv g')) ≃〈 ap (λ x → KG1.loop g' ∘ x) {!! (KG1.loop-comp (inv g') g)!} 〉 
                         (KG1.loop g') ∘ KG1.loop (comp (inv g') g) ≃〈 {!!} 〉 
                         KG1.loop (comp (comp (inv g') g) g') ≃〈 {!!} 〉 
                         KG1.loop (comp (comp g (inv g')) g) ≃〈 {!!} 〉 
                         KG1.loop (comp g (comp (inv g') g)) ≃〈 {!!} 〉 
                         KG1.loop (comp g ident) ≃〈 {!!} 〉 
                         KG1.loop g ∎


    mult : KG1 -> KG1 -> KG1 
    mult = KG1-rec (Πlevel (λ _ → KG1.level)) 
                   (λ x → x)
                   (record { f = λ g → λ≃ (mult-loop g);
                             pres-ident = ! (Π≃η id) ∘ ap λ≃ (λ≃ (KG1-elim (λ x → _ , path-preserves-level (path-preserves-level KG1.level))
                                                                          KG1.loop-ident
                                                                          (λ _ → trivial1 KG1.level)
                                                                          (λ _ → trivial1 (path-preserves-level KG1.level))
                                                                          (λ _ _ → trivial1 (path-preserves-level KG1.level))));
                             pres-comp = λ g1 g2 → ! (∘λ≃ _ _) ∘ ap λ≃ (λ≃ (KG1-elim
                                                                              (λ x → _ , path-preserves-level (path-preserves-level KG1.level)) 
                                                                              (KG1.loop-comp g1 g2)
                                                                              (λ _ → trivial1 KG1.level)
                                                                              (λ _ → trivial1 (path-preserves-level KG1.level))
                                                                              (λ _ _ → trivial1 (path-preserves-level KG1.level)))) })

    mult-isequiv : (x : KG1) → IsEquiv (mult x)
    mult-isequiv = KG1-elim (\ x -> _ , raise-HProp (IsEquiv-HProp _))
                            (snd id-equiv)
                            (λ x → HProp-unique (IsEquiv-HProp _) _ _)
                            (λ _ → HSet-UIP (increment-level (IsEquiv-HProp _)) _ _ _ _)
                            (λ _ _ → HSet-UIP (increment-level (IsEquiv-HProp _)) _ _ _ _)

    H-KG1 : H-Structure KG1 KG1.base
    H-KG1 = record { _⊙_ = mult; 
                     unitl = KG1-elim (λ x → mult KG1.base x ≃ x , path-preserves-level KG1.level)
                                      id
                                      (λ g → (!-inv-r (ap (λ x → x) (KG1.loop g)) ∘ 
                                              ∘-assoc (ap (λ x → x) (KG1.loop g)) id (! (ap (λ x → x) (KG1.loop g)))) ∘
                                              transport-Path (λ x → x) (λ x → x) (KG1.loop g) id) 
                                      (\ _ -> trivial1 KG1.level) 
                                      (\ _ _ -> trivial1 KG1.level);
                     unitr = KG1-elim
                               (λ x → mult x KG1.base ≃ x , path-preserves-level KG1.level)
                               id
                               -- should work
                               (λ x → (transport (λ x' → mult x' KG1.base ≃ x') (KG1.loop x) id) ≃〈 {!!} 〉 
                                      (ap (\ x -> x) (KG1.loop x) ∘ id ∘ ap (λ x' → mult x' KG1.base) (! (KG1.loop x))) ≃〈 {!!} 〉 
                                      ((KG1.loop x) ∘ id ∘ ap (λ x' → mult x' KG1.base) (! (KG1.loop x))) ≃〈 {!!} 〉 
                                      ((KG1.loop x) ∘ ap (λ x' → mult x' KG1.base) (! (KG1.loop x))) ≃〈 {!!}  〉
                                      ((KG1.loop x) ∘ ! (ap (λ x' → mult x' KG1.base) (KG1.loop x))) ≃〈 {!!}  〉
                                      ((KG1.loop x) ∘ ! (ap≃ (ap mult (KG1.loop x)) {KG1.base})) ≃〈 {!!}  〉 -- 2 steps
                                      ((KG1.loop x) ∘ ! (KG1.loop x)) ≃〈 {!!}  〉
                                      id ∎)
                               (λ _ → trivial1 KG1.level) (λ _ _ → trivial1 KG1.level); 
                     unitcoh = id;
                     isequivl = mult-isequiv }

  module Pi1 (G : Group) where

    open Group G

    module KG1 = K G
    open KG1 using (KG1 ; KG1-rec ; KG1-elim)

    comp-equiv : ∀ g -> Equiv El El
    comp-equiv a = (improve (hequiv (\ x -> comp x a)
                                    (\ x -> comp x (inv a)) 
                                    (λ x → (unitr x ∘ ap (λ y → comp x y) (invr a)) ∘ assoc x a (inv a))
                                    (λ x → (unitr x ∘ ap (λ y → comp x y) (invl a)) ∘ assoc x (inv a) a)))

    decode' : El → Path{KG1} KG1.base KG1.base
    decode' = KG1.loop

    Codes : KG1 → NTypes (tl 0)
    Codes = KG1-rec (NTypes-level (tl 0))
                    (El , El-level)
                    (record { f = λ g → coe (! (Path-NTypes (tl 0))) (ua (comp-equiv g));
                              pres-ident = {!!};
                              pres-comp = {!!} })

    transport-Codes-loop : ∀ g g' -> (transport (fst o Codes) (KG1.loop g) g') ≃ comp g' g
    transport-Codes-loop = {!!}
                       -- coe (ap (fst o Codes) (KG1.loop x)) ident ≃〈 {!!} 〉 
                       -- coe (fst≃ (coe (! (Path-NTypes (tl 0))) (ua (comp-equiv x)))) ident ≃〈 {!!} 〉 
                       -- coe (ua (comp-equiv x)) ident ≃〈 {!!} 〉 

    encode : {x : KG1} -> Path KG1.base x -> fst (Codes x)
    encode α = transport (fst o Codes) α ident

    encode-decode' : ∀ x -> encode (decode' x) ≃ x
    encode-decode' x = encode (decode' x) ≃〈 id 〉 
                       encode (KG1.loop x) ≃〈 id 〉 
                       transport (fst o Codes) (KG1.loop x) ident ≃〈 transport-Codes-loop x ident 〉 
                       comp ident x ≃〈 unitl x 〉 
                       x ∎
    
    decode : {x : _} -> fst (Codes x) -> Path KG1.base x
    decode {x} = KG1-elim (λ x' → (fst (Codes x') → Path KG1.base x') , Πlevel (λ _ → path-preserves-level KG1.level))
                          decode'
                          (λ g → transport-→-from-square (fst o Codes) (Path KG1.base) (KG1.loop g) decode' decode'
                                 (λ≃ (\ g' -> 
                                   (transport (Path KG1.base) (KG1.loop g) (decode' g') ≃〈 id 〉
                                    transport (Path KG1.base) (KG1.loop g) (KG1.loop g') ≃〈 transport-Path-right (KG1.loop g) (KG1.loop g') 〉
                                    (KG1.loop g) ∘ (KG1.loop g') ≃〈 ! (KG1.loop-comp g' g) 〉
                                    KG1.loop (comp g' g) ≃〈 ap KG1.loop (! (transport-Codes-loop g g')) 〉 
                                    KG1.loop (transport (fst o Codes) (KG1.loop g) g') ≃〈 id 〉 
                                    decode' (transport (fst o Codes) (KG1.loop g) g') ∎))))
                          (λ _ → HSet-UIP (Πlevel (λ _ → use-level KG1.level _ _)) _ _ _ _)
                          (λ _ _ → HSet-UIP (Πlevel (λ _ → use-level KG1.level _ _)) _ _ _ _)
                          x