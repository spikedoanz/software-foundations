# intros  [binding names for hypotheses / variables].

1. binds a variable from a forall in a hypothesis
  ```
  Γ, h : forall a : x, y |- Δ
  --------------------------- intros a.
  Γ, a : x, h : y |- Δ
  ```

2. ditto for when the forall is in the goal
  ```
  Γ |- forall a : x, y
  -------------------- intros h.
  Γ, a : x |- y
  ```
3. introduces the explicit assumption in the goal as a hypothesis
  ```
  Γ |- a -> b 
  ----------- intros h.
  Γ, h : a |- b 
  ```
--------------------------------------------------------------------------------
# reflexivity.

1. discharges goals of type a = a
  ```
  Γ |- a = a
  ---------- reflexivity.

  ```
--------------------------------------------------------------------------------
# apply [thing] [_in_ + something on the lhs of sequent].

1. discharges goal when a hypothesis is the same as the goal.
  ```
  Γ, H : a |- a 
  ------------- apply H. Qed.

  ``` 

2. moves the goal backwards when applied to the goal
  ```
  Γ, H : a -> b |- b
  ------------------ apply H.
  Γ |- a  
  ```

3. moves a hypothesis forward when applied to something on the lhs
  ```
  Γ, x : a, H : a -> b |- Δ 
  --------------------------  apply x at h. 
  Γ, h : b |- Δ
  ```
    > syntax cruft, but image slapping x into the first slot
  
-------------------------------------------------------------------------------- 
# apply [thing] [_with_ some variables].

1. manually specify variables that coq doesn't know how to specialize
  ```
  Γ, h : forall (x : A) (y : B), P x -> Q y -> R,
  |- Δ
  ----------------------------------------------- apply h with a b
  (1/2)
  Γ, h : forall (x : A) (y : B), P x -> Q y -> R
  |- P a

  (2/2)
  Γ, h : forall (x : A) (y : B), P x -> Q y -> R
  |- Q b
  ```

--------------------------------------------------------------------------------
# simpl [_in_ hypothesis].
  > selectively does heuristic 
    beta  reductions (function apps), 
    delta reductions (unfolding definitions)
    iota  reductions (match / fix evaluation)
    zeta  reductions (let binding resolutions)
    until it reaches a "nice" form.
    doesn't really have nice structural properties. basically a shotgun.

--------------------------------------------------------------------------------
# rewrite [_in_ hypothesis].
1. uses an equality hypotheis to change the goal or a different hypothesis's
variables.
  ```
  Γ, h : a = b |- a = c
  --------------------- rewrite h.
  Γ, h : a = b |- b = c
  ```
2. also works in hypotheses
  ```
  Γ, h : a = b, h': a |- Δ
  ------------------------ apply h in h'.
  Γ, h : a = b, h': b |- Δ
  ```

--------------------------------------------------------------------------------
# symmetry [_in_ hypothesis]
1. flips an equality

--------------------------------------------------------------------------------
# transitivity [some intermediate variable]
1. transforms the goal from an x = z into two goals, x = y and y = z
  ```
  Γ |- x = z
  ---------- transitivity y
  (1/2)
  Γ |- x = y
  (2/2)
  Γ |- y = z
  ```

--------------------------------------------------------------------------------
# unfold [_in_ hypothesis].
# destruct [_as_ some name] [_eqn:_ other name to keep original].
# induction [_as_ some names].
# injection [_as_].
# discriminate.
# assert (H: e) / assert (e) as H.
# generalize dependent x.
# f_equal.
  


