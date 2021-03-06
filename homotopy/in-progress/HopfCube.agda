
{-# OPTIONS --type-in-type --without-K #-}

open import lib.Prelude
open import lib.cubical.Cubical
open import lib.spaces.2SphereCube
open import lib.spaces.3SphereCube

module homotopy.HopfCube where

  module S² = S²Cube
  module S³ = S³Cube

  H-square2-and-cube : Σ \ (s : Square S¹.loop
                                       (ap (λ z → z) S¹.loop)
                                       (ap (λ z → z) S¹.loop)
                                       S¹.loop ) → 
                      Cube s (sides-same-square S¹.loop) hrefl-square (horiz-degen-square (ap-id S¹.loop)) (horiz-degen-square (ap-id S¹.loop)) hrefl-square
  H-square2-and-cube = fill-cube-left (sides-same-square S¹.loop) hrefl-square (horiz-degen-square (ap-id S¹.loop)) (horiz-degen-square (ap-id S¹.loop)) hrefl-square                                       

  H-square : Square{Type}{S¹.S¹} id id id id
  H-square = in-square-Type (S¹.S¹-elimo _ S¹.loop (PathOver=.in-PathOver-= (fst H-square2-and-cube)))

  postulate 
    SquareOver-H-Square-eqv : {b1 b2 b3 b4 : S¹.S¹} 
           {l : PathOver (\ x -> x) id b1 b2} 
           {t : PathOver (\ x -> x) id b1 b3}
           {b : PathOver (\ x -> x) id b2 b4}
           {r : PathOver (\ x -> x) id b3 b4}
         → Equiv (SquareOver (\ X -> X) H-square l t b r)
                 (Square (over-to-hom/left (b ∘o l))
                         (S¹.S¹-elimo _ S¹.loop (PathOver=.in-PathOver-= (fst H-square2-and-cube)) b1)
                         id
                         (over-to-hom/left (r ∘o t)))

  H : S².S² → Type
  H = S².S²-rec S¹.S¹ H-square




{-
  interchange : {A : Type}
              {a00 a01 a10 a11 : A} 
              {left1 : a00 == a01}
              {top1 : a00 == a10}
              {bot1 : a01 == a11}
              {right1 : a10 == a11}
              (upleft : Square left1 top1 bot1 right1)
              {a20 a21 : A} 
              {top2 : a10 == a20}
              {bot2 : a11 == a21}
              {right2 : a20 == a21}
              (upright : Square right1 top2 bot2 right2)
              {a02 a12 : A} 
              {left3 : a01 == a02}
              {bot3 : a02 == a12}
              {right3 : a11 == a12}
              (lowleft : Square left3 bot1 bot3 right3)
              {a22 : A} 
              {bot4 : a12 == a22}
              {right4 : a21 == a22}
              (lowright : Square right3 bot2 bot4 right4)
              → (upleft ∘-square-h upright) ∘-square-v (lowleft ∘-square-h lowright)
              == (upleft ∘-square-v lowleft) ∘-square-h (upright ∘-square-v lowright)
  interchange {left1 = id} s1 id id {bot4 = id} s4 = {!!}

  ap-interchange : {A B : Type}
              {a00 a01 a10 a11 : A} 
              {left1 : a00 == a01}
              {top1 : a00 == a10}
              {bot1 : a01 == a11}
              {right1 : a10 == a11}
              (upleft : Square left1 top1 bot1 right1)
              {a20 a21 : A} 
              {top2 : a10 == a20}
              {bot2 : a11 == a21}
              {right2 : a20 == a21}
              (upright : Square right1 top2 bot2 right2)
              {a02 a12 : A} 
              {left3 : a01 == a02}
              {bot3 : a02 == a12}
              {right3 : a11 == a12}
              (lowleft : Square left3 bot1 bot3 right3)
              {a22 : A} 
              {bot4 : a12 == a22}
              {right4 : a21 == a22}
              (lowright : Square right3 bot2 bot4 right4)
              (f : A → B) → 
              ap-cube f (degen-cube-h (interchange upleft upright lowleft lowright))
              == {!degen-cube-h (interchange (ap-square f upleft) (ap-square f upright) (ap-square f lowleft) (ap-square f lowright))    !}
  ap-interchange = {!!}

  int-id-s-!s-id-1 : {A : Type}
              {a20 : A} 
              {top2 : a20 == a20}
              (upright : Square id top2 id id)
              → Cube id
                     ((id ∘-square-h upright) ∘-square-v
                       (!-square-v upright ∘-square-h id))
                     id
                     (!-square-h (square-symmetry upright))
                     (!-square-h (square-symmetry upright) ∘-square-h ∘-square {p = top2} {q = id})
                     id
  int-id-s-!s-id-1 = {!!}

  int-id-s-!s-id-2 : {A : Type}
              {a20 : A} 
              {top2 : a20 == a20}
              (upright : Square id top2 id id)
              → Cube 
                     ((id ∘-square-v !-square-v upright) ∘-square-h
                       (upright ∘-square-v id))
                     id
                     id
                     ((square-symmetry upright))
                     (!-square-h (!-square-h (square-symmetry upright) ∘-square-h ∘-square {p = top2} {q = id}))
                     id
  int-id-s-!s-id-2 = {!!}
-}

  degen-square-h-path-eqv : {A : Type}
                 {a a' : A} 
                 {top : a == a'}
                 {bot : a == a'}
                 → Equiv (Square id top bot id)
                         (bot == top)
  degen-square-h-path-eqv {top = top} = improve (hequiv ((λ p → ∘-unit-l top ∘ p) o square-to-disc) (!-square-v o vertical-degen-square) FIXME FIXME) where
    postulate FIXME : {A : Type} → A
  

  -- the specific case we need, with upleft = id, botright = id, and botleft = !v upright
  interchange' : {A : Type}
                 {a20 : A} 
                 {top2 : a20 == a20}
                 (upright : Square id top2 id id)
               → Cube 
                     ((!-square-v upright) ∘-square-h upright)
                     (upright ∘-square-v (!-square-v upright))
                     id
                     hrefl-square
                     (!-square-h (∘-square {q = id}))
                     id
  interchange' = elim-along-equiv _ (!equiv degen-square-h-path-eqv) (path-induction
                                                                        (λ top2 x →
                                                                           Cube
                                                                           (!-square-v (fst (!equiv degen-square-h-path-eqv) x) ∘-square-h
                                                                            fst (!equiv degen-square-h-path-eqv) x)
                                                                           (fst (!equiv degen-square-h-path-eqv) x ∘-square-v
                                                                            !-square-v (fst (!equiv degen-square-h-path-eqv) x))
                                                                           id hrefl-square (!-square-h ∘-square) id)
                                                                        id) 
  H-SquareOver : SquareOver H S².loop id (hom-to-over/left id (! S¹.loop)) id id 
  H-SquareOver = {!!} where 
    goal1 : SquareOver (\ x -> x) (ap-square H S².loop) id (hom-to-over/left id (! S¹.loop)) id id 
    goal1 = {!!}

    goal2 : SquareOver (\ x -> x) (H-square) id (hom-to-over/left id (! S¹.loop)) id id 
    goal2 = ine SquareOver-H-Square-eqv (disc-to-square {!!})

  ΣH-square : Square {Σ H} (pair= id id) (pair= id (hom-to-over/left id (! S¹.loop))) (pair= id id) (pair= id id) 
  ΣH-square = ine SquareΣ-eqv-intro (S².loop , H-SquareOver)


  test' : Cube (!-square-v H-square ∘-square-h H-square)
            (H-square ∘-square-v !-square-v H-square) id id
            id id
  test' = interchange' H-square

  S²-int : Cube{S².S²}{S².base} id id id id id id
  S²-int = {!interchange' S².loop!}
    -- whisker-cube id id id {!!} {!!} id (int-id-s-!s-id-1 S².loop ∘-cube-h 
    --                                           degen-cube-h (interchange id S².loop (!-square-v S².loop) id) ∘-cube-h
    --                                           int-id-s-!s-id-2 S².loop)

  postulate
  -- should be trivial by h-level reasons... should be a Cube in S¹
      3t2-cube : CubeOver H {S¹.base} S²-int id id id id id id 

  3t2 : S³.S³ → Σ H
  3t2 = S³.S³-rec (S².base , S¹.base)
                  id

  SquareOver-H-loop-pathover : (b100 : S¹.S¹) → PathOver H (id{_}{S².base}) b100 b100
  SquareOver-H-loop-pathover = \b100 → (hom-to-over/left id (! (S¹.S¹-elimo _ S¹.loop (PathOver=.in-PathOver-= (fst H-square2-and-cube)) b100)))

  postulate
   SquareOver-H-loop-squareover : (b100 : S¹.S¹) → SquareOver H S².loop id id id (SquareOver-H-loop-pathover b100)

   SquareOver-H-loop-with-boundary-eqv' : ∀ {C : (b100 : S¹.S¹) (b110 : S¹.S¹) (b101 : S¹.S¹) (b111 : S¹.S¹)
           (q10- : PathOver H id b100 b101)
           (q1-0 : PathOver H id b100 b110)
           (q1-1 : PathOver H id b101 b111)
           (q11- : PathOver H id b110 b111) →
           (f1 : SquareOver H S².loop q10- q1-0 q1-1 q11-) → Type} → 
    Equiv ((b100 : S¹.S¹) (b110 : S¹.S¹) (b101 : S¹.S¹) (b111 : S¹.S¹)
           (q10- : PathOver H id b100 b101)
           (q1-0 : PathOver H id b100 b110)
           (q1-1 : PathOver H id b101 b111)
           (q11- : PathOver H id b110 b111) →
           (f1 : SquareOver H S².loop q10- q1-0 q1-1 q11-) → C _ _ _ _ q10- q1-0 q1-1 q11- f1)
          ((b100 : S¹.S¹) → C b100 b100 b100 b100 id id id (SquareOver-H-loop-pathover b100)
                                                            (SquareOver-H-loop-squareover b100))
    

  postulate
    sides-same-cube : 
      {A : Type} {a000 : A}  
      {p0-0 : a000 == a000}
      {p-00 : a000 == a000}
      (f--0 : Square p0-0 p-00 p-00 p0-0) -- left
      {p00- : a000 == a000}
      {p11- : a000 == a000}
      (f0-- : Square p0-0 p00- p00- p0-0) -- back
      (f-0- : Square p-00 p00- p00- p-00) -- top
      → Cube f--0 f--0 f0-- f-0- f-0- f0--

  2t3-f : S¹.S¹ → Square {_}{S³.base} id id id id
  2t3-f = S¹.S¹-elimo _ id (coe (! (PathOver-square/= S¹.loop id id)) (S³.loop ∘-cube-h (sides-same-cube _ _ _) )) 

  2t3 : (x : S².S²) → H x → S³.S³
  2t3 = S².S²-elim _ (\ _ -> S³.base) 
                     (ine SquareOver-Π-eqv (ine SquareOver-H-loop-with-boundary-eqv' 
                       (λ b100 → ine SquareOver-constant-eqv 
                                 (2t3-f b100 ∘-square-h
                                  disc-to-square (! (ap (oute PathOver-constant-eqv) (out-PathOverΠ-constant _ _))
                                                    ∘ ! (IsEquiv.β (snd PathOver-constant-eqv) id)))))) where
        out-PathOverΠ-constant : {Δ : Type} {A : Δ → Type} {B : Type}
              → {θ1 : Δ} {b : B} 
              → {x : A θ1} (y : _) (β : PathOver A id x y) 
              → oute PathOverΠ-eqv (id {_} {_} {_} {λ _ → b}) x y β == ine PathOver-constant-eqv id
        out-PathOverΠ-constant = path-induction-homo-e _ id

  2t3' : Σ H → S³.S³
  2t3' (x , y) = 2t3 x y

  red1 : Cube (ap-square 2t3' ΣH-square) (oute SquareOver-constant-eqv
                                            (oute SquareOver-Π-eqv (apdo-square 2t3 S².loop) S¹.base S¹.base
                                             S¹.base S¹.base id (hom-to-over/left id (! S¹.loop)) id id
                                             H-SquareOver))
                                         _ _ _ _ 
  red1 = ap-bifunctor-square 2t3 _ _

  3t2t3 : (x : S³.S³) → (2t3' (3t2 x)) == x
  3t2t3 = S³.S³-elim _ id {!  !}  where
    test : ap-cube (2t3' o 3t2) S³.loop == S³.loop
    test = ap-cube (2t3' o 3t2) S³.loop ≃〈 {!!} 〉 
           ap-cube 2t3' (ine (CubeΣ-eqv{f--0 = id}{f--1 = id}{f0-- = id}{f-0- = id}{f-1- = id}{f1-- = id}) (S²-int , 3t2-cube)) ≃〈 {!!} 〉
           coe {!!}
              (coe (PathOver-square/= _ _ _)
                 (apdo
                  (oute SquareOver-constant-eqv od1
                   oute SquareOver-H-loop-with-boundary-eqv'
                   (oute SquareOver-Π-eqv (apdo-square 2t3 S².loop)))
                  S¹.loop)) ≃〈 {!!} 〉  -- (λ x → ap (λ y → 2t3 x y) {!!})
           S³.loop ∎


{-
  2t3t2 : (x : S².S²) (y : H x) → 3t2 (2t3 x y) == (x , y)
  2t3t2 = S².S²-elim _ (S¹.S¹-elimo _ id (PathOver=.in-PathOver-= square1))
                       (ine (SquareOver-Π-eqv) (ine SquareOver-H-loop-with-boundary-eqv' 
                            (SquareOver=ND.in-SquareOver-= od1 
                             whisker-cube vrefl-square-symmetry {!!} vrefl-square-symmetry id id vrefl-square-symmetry
                             od1 cube-symmetry-left-to-top od1 (S¹.S¹-elimo _ cube1 {!!})))) where
        -- FIXME: why does square1 drop out of the later goals?

        square1 : _ -- Square id (ap (λ z → 3t2 (2t3 S².base z)) S¹.loop) (ap (λ z → S².base , z) S¹.loop) id
        square1 = {!!}

        square2 : _ {- Square
             (ap (λ v → 3t2 (2t3 (fst v) (snd v)))
              (pair= id (SquareOver-H-loop-pathover S¹.base)))
             (S¹.S¹-elimo (λ x → 3t2 (2t3 S².base x) == (S².base , x)) id
              (PathOver=.in-PathOver-= square1) S¹.base)
             (S¹.S¹-elimo (λ x → 3t2 (2t3 S².base x) == (S².base , x)) id
              (PathOver=.in-PathOver-= square1) S¹.base)
             (ap (λ v → fst v , snd v)
              (pair= id (SquareOver-H-loop-pathover S¹.base))) -}
        square2 = {!!}

        cube1 : Cube _ _ _ _ _ square2
        cube1 = {!!}

        thing1 : _
        thing1 = coe (PathOver-square/= _ _ _) (apdo (\ z -> (ap-square (λ v → 3t2 (2t3 (fst v) (snd v))) (ine SquareΣ-eqv-intro (S².loop , SquareOver-H-loop-squareover z)))) S¹.loop)

        thing2 : _
        thing2 = coe (PathOver-square/= _ _ _) (apdo (\ z -> (ap-square (λ v → fst v , snd v) (ine SquareΣ-eqv-intro (S².loop , SquareOver-H-loop-squareover z)))) S¹.loop)

        test : thing1 == {!!}
        test = {!!}
-}

{-
  test : {b1 b2 b3 b4 : S¹.S¹} 
         {l : PathOver (\ x -> x) id b1 b2} 
         {t : PathOver (\ x -> x) id b1 b3}
         {b : PathOver (\ x -> x) id b2 b4}
         {r : PathOver (\ x -> x) id b3 b4}
       → Equiv (SquareOver (\ X -> X) H-square l t b r)
               (Square (over-to-hom/left (b ∘o l))
                       (S¹.S¹-elimo _ S¹.loop (PathOver=.in-PathOver-= (fst H-square2-and-cube)) b1)
                       id
                       (over-to-hom/left (r ∘o t)))
  test = {! squareover-El-eqv {s = H-square} !}

  test' : {b1 : S¹.S¹} 
         {r : PathOver (\ x -> x) id b1 b1}
       → Equiv (SquareOver (\ X -> X) H-square id id id r)
               (Square id
                       (S¹.S¹-elimo _ S¹.loop (PathOver=.in-PathOver-= (fst H-square2-and-cube)) b1)
                       id
                       (over-to-hom/left r))
  test' = {! squareover-El-eqv {s = H-square} !}

  -- r = ! (S¹.S¹-elimo _ S¹.loop (PathOver=.in-PathOver-= (fst H-square2-and-cube)) b1)

  test2 : PathOver {Type} (λ X → X) {S¹.S¹} {S¹.S¹} id S¹.base S¹.base 
  test2 = {!!}
-}
