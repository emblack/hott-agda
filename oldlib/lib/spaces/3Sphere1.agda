{-# OPTIONS --type-in-type --without-K #-}

open import lib.BasicTypes 

module lib.spaces.3Sphere1 where

  open Paths

  module S³1 where
    private
      data S3 : Set where
        Base : S3

    S³ : Set
    S³ = S3

    base : S³
    base = Base

    postulate
      loop : Id{Id {Id base base} Refl Refl} Refl Refl

    S³-rec : {C : Set} 
           -> (base' : C)
           -> (loop' : Id{Id {Id base' base'} Refl Refl} Refl Refl)
           -> S³ -> C
    S³-rec base' _ Base  = base'

    -- FIXME
{-
    S²-elim : (C : S² -> Set)
            -> (a' : C a)(b' : C b)
            -> (n' : subst C n a' ≃ b') (s' : subst C s a' ≃ b')
            -> (fr' : subst (\ y -> Id (subst C y a') b') fr n' ≃ s') 
            -> (ba' : subst (\ y -> Id (subst C y a') b') ba n' ≃ s') 
            -> (x : S²) -> C x
    S²-elim C a' _ _ _ _ _ A = a'
    S²-elim C _ b' _ _ _ _ B = b'

    module Rec where 
     postulate
      βn :  {C : Set} 
             -> (a' : C)(b' : C)
             -> (n' : a' ≃ b') (s' : a' ≃ b')
             -> (fr' : n' ≃ s') (ba' : n' ≃ s')
             -> resp (S²-rec a' b' n' s' fr' ba') n ≃ n' 
      βs :  {C : Set} 
             -> (a' : C)(b' : C)
             -> (n' : a' ≃ b') (s' : a' ≃ b')
             -> (fr' : n' ≃ s') (ba' : n' ≃ s')
             -> resp (S²-rec a' b' n' s' fr' ba') s ≃ s' 
      βfr :  {C : Set} 
             -> (a' : C)(b' : C)
             -> (n' : a' ≃ b') (s' : a' ≃ b')
             -> (fr' : n' ≃ s') (ba' : n' ≃ s')
             -> resp (resp (S²-rec a' b' n' s' fr' ba')) fr ≃ (! (βs _ _ _ _ _ _) ∘ fr' ∘ βn _ _ _ _ _ _)
      βba :  {C : Set} 
             -> (a' : C)(b' : C)
             -> (n' : a' ≃ b') (s' : a' ≃ b')
             -> (fr' : n' ≃ s') (ba' : n' ≃ s')
             -> resp (resp (S²-rec a' b' n' s' fr' ba')) ba ≃ (! (βs _ _ _ _ _ _) ∘ ba' ∘ βn _ _ _ _ _ _)
-}

