Require Import
  Morphisms Program
  abstract_algebra interfaces.monads jections.

Section contents.
  Context A `{Setoid A}.

  Inductive option_equiv: Equiv (option A) :=
    | option_equiv_Some x₁ x₂ : x₁ = x₂ → Some x₁ = Some x₂
    | option_equiv_None : None = None.
  Existing Instance option_equiv.
  Hint Constructors option_equiv.

  Lemma Some_ne_None x : Some x ≠ None.
  Proof. intros E. inversion E. Qed.

  Lemma None_ne_Some x : None ≠ Some x.
  Proof. intros E. inversion E. Qed.

  Global Instance: Setoid (option A).
  Proof.
    split.
      intros [x|]. now apply option_equiv_Some. now apply option_equiv_None.
     red. induction 1. now apply option_equiv_Some. now apply option_equiv_None.
    intros x y z E. revert z. induction E.
     intros z E2. inversion_clear E2.
     apply option_equiv_Some. now transitivity x₂. 
    easy.
  Qed.

  Global Instance: Setoid_Morphism Some.
  Proof. split; try apply _. intros ? ? ?. now apply option_equiv_Some. Qed.

  Global Instance: Injective Some.
  Proof. split; try apply _. intros ? ? E. now inversion E. Qed.

  Program Instance option_dec `(A_dec : ∀ x y : A, Decision (x = y))
     : ∀ x y : option A, Decision (x = y) := λ x y,
    match x with
    | Some r => 
      match y with
      | Some s => match A_dec r s with left _ => left _ | right _ => right _ end
      | None => right _
      end
    | None =>
      match y with
      | Some s => right _
      | None => left _
      end
    end.
  Next Obligation. now apply (injective_ne Some). Qed.
  Next Obligation. apply Some_ne_None. Qed.
  Next Obligation. apply None_ne_Some. Qed.
End contents.

Hint Extern 10 (Equiv (option _)) => apply @option_equiv : typeclass_instances. 

Instance option_ret: MonadReturn option := λ A x, Some x.
Instance option_bind: MonadBind option := λ A B x f,
  match x with
  | Some a => f a
  | None => None
  end.

Instance option_ret_proper `{Equiv A} : Proper ((=) ==> (=)) (option_ret A).
Proof. intros x y E. now apply option_equiv_Some. Qed.

Instance option_bind_proper `{Setoid A} `{Setoid B}: Proper (=) (option_bind A B).
Proof.
  intros x₁ x₂. destruct 1.
   intros f₁ f₂ E₂. unfold option_bind. simpl.
   now apply (E₂ x₁ x₂).
  easy.
Qed.

Instance: Monad option.
Proof.
  repeat (split; try apply _); unfold bind, ret, option_bind, option_ret.
    easy.
   now intros ? ? ? [x|].
  intros ? ? ? ? ? ? ? ? ? [x|] f g.
   now destruct (f x).
  easy.
Qed.