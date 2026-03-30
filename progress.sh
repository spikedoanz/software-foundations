#!/bin/bash
# Software Foundations progress tracker
# Shows completed vs remaining Admitted proofs per chapter

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

cd "$(dirname "$0")"

# Count "Admitted." outside of (* ... *) comments
count_admitted() {
    local n
    n=$(perl -0777 -pe 's/\(\*.*?\*\)//gs' | grep -c "Admitted\.")
    echo "${n:-0}"
}

# Chapter order from toc.html
LF_ORDER=(Basics Induction Lists Poly Tactics Logic IndProp Maps ProofObjects IndPrinciples Rel Imp ImpCEvalFun Auto AltAuto)
PLF_ORDER=(Equiv Hoare Hoare2 HoareAsLogic Smallstep Types Stlc StlcProp MoreStlc Sub Typechecking Records References RecordSub Norm UseTactics UseAuto)
VFA_ORDER=(Perm Sort Multiset BagPerm Selection Merge Maps SearchTree ADT Extract Redblack Trie Priqueue Binom Decide Color)

# Global accumulators
grand_orig=0
grand_done=0

print_book() {
    local book="$1"
    local book_name="$2"
    shift 2
    local chapters=("$@")
    local total_orig=0
    local total_done=0

    echo ""
    echo -e "${BOLD}${CYAN}=== $book_name ===${RESET}"
    echo ""

    for chapter in "${chapters[@]}"; do
        local f="$book/${chapter}.v"
        [ -f "$f" ] || continue

        first_commit=$(git log --diff-filter=A --format="%H" -- "$f" | tail -1)
        [ -z "$first_commit" ] && continue

        orig=$(git show "$first_commit:$f" 2>/dev/null | count_admitted)
        orig=$((orig + 0))
        [ "$orig" -eq 0 ] && continue

        now=$(count_admitted < "$f")
        now=$((now + 0))
        done=$((orig - now))
        [ "$done" -lt 0 ] && done=0

        total_orig=$((total_orig + orig))
        total_done=$((total_done + done))

        remaining=$((orig - done))

        if [ "$done" -eq "$orig" ]; then
            color="$GREEN"
            tag="DONE"
        elif [ "$done" -gt 0 ]; then
            color="$YELLOW"
            tag="${done}/${orig}"
        else
            color="$RED"
            tag="${done}/${orig}"
        fi

        dots=""
        crosses=""
        [ "$done" -gt 0 ] && dots=$(printf '.%.0s' $(seq 1 $done))
        [ "$remaining" -gt 0 ] && crosses=$(printf 'X%.0s' $(seq 1 $remaining))

        printf "  %-18s ${GREEN}%s${RED}%s${RESET}  ${color}(%s)${RESET}\n" \
            "$chapter" "$dots" "$crosses" "$tag"
    done

    echo ""
    pct=0
    [ "$total_orig" -gt 0 ] && pct=$((total_done * 100 / total_orig))
    echo -e "  ${BOLD}Total: ${total_done}/${total_orig} proofs completed (${pct}%)${RESET}"

    grand_orig=$((grand_orig + total_orig))
    grand_done=$((grand_done + total_done))
}

echo ""
echo -e "${BOLD}  Software Foundations Progress${RESET}"

print_book "lf" "Logical Foundations (Vol. 1)" "${LF_ORDER[@]}"
print_book "plf" "Programming Language Foundations (Vol. 2)" "${PLF_ORDER[@]}"
print_book "vfa" "Verified Functional Algorithms (Vol. 3)" "${VFA_ORDER[@]}"

echo ""
gpct=0
[ "$grand_orig" -gt 0 ] && gpct=$((grand_done * 100 / grand_orig))

# progress bar
bar_width=40
filled=$((grand_done * bar_width / grand_orig))
empty=$((bar_width - filled))
echo -ne "  ${BOLD}Overall: ["
echo -ne "${GREEN}"
[ "$filled" -gt 0 ] && printf '.%.0s' $(seq 1 $filled)
echo -ne "${DIM}${RED}"
[ "$empty" -gt 0 ] && printf 'X%.0s' $(seq 1 $empty)
echo -e "${RESET}${BOLD}] ${grand_done}/${grand_orig} (${gpct}%)${RESET}"
echo ""
