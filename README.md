# Claude Code: Principles

*Dave Figueroa*

Working principles from hands-on Claude Code configuration across multiple projects, developed through my CodeGarage, a meta-project for auditing, tuning, and incubating Claude Code infrastructure.

Configuration is the work of giving Claude what it needs to do good work: orientation, judgment-bearing context, and the right tool at the right layer. Claude has strong defaults; configuration earns its keep by directing where defaults aren't enough, not by cataloguing what to avoid. Every line in front of Claude shapes what it attends to; lines that don't shape attention dilute the ones that do. Configuration done well lets you write the spec, hand off the work, and get out of the way.

---

## I. Context Economics

### 1. Dilution Is the Failure Mode

Everything in context competes for attention. The failure mode isn't just wasted tokens — it's dilution. Larger context windows don't relieve dilution; they amplify it, because the visible cost of adding a rule keeps falling while the attention cost doesn't. A long list of "don't do X" rules becomes background noise by the time the specific edge case arrives. The model stops distinguishing between critical guardrails and cautionary notes. Every turn an agent spends processing unnecessary context is spend that bought no judgment. Context efficiency is simultaneously a quality, reliability, and cost concern.

### 2. The Single Line Test

Every line in your configuration should pass one test: **"Would removing this line cause Claude to make a mistake?"** If not, cut it. The test's strictness varies by where the line loads. Root CLAUDE.md is strictest: it loads for every session, every agent. An agent prompt that loads once for a single judgment-heavy session has a different cost calculus; comprehensiveness there is often correct.

### 3. Lean at the Top, Deep Where Judgment Compounds

CLAUDE.md is the most expensive real estate; agent prompts are the cheapest. Be strict where context loads always, comprehensive where it loads once. A lean CLAUDE.md frees budget for depth in agent prompts, and that's where it matters most. Agent prompts for judgment-heavy, single-purpose agents are the highest-return investment in your entire configuration.

Within agent prompts, depth pays most where an agent's judgment shapes what comes after it, such as a plan or a review, or where nothing checks its work afterward. An agent carrying out a settled plan, with a review behind it, can stay lean.

### 4. Just-in-Time Knowledge

Instructions are most effective when they arrive at the moment they're contextually relevant, not preloaded as permanent weight. Path-scoped rules load when Claude touches matching files. Skills load when invoked. Agent prompts deliver context at spawn time. A well scoped rules file for one domain doesn't eat context during work in another. The request you type in session arrives last of all, and an instruction there outweighs the same line in CLAUDE.md.

### 5. CLAUDE.md Answers One Question

CLAUDE.md answers: **"What is this project and where are things?"** Project identity, architecture pointers, fragile areas. Behavioral rules, domain knowledge, and process instructions all have better homes: places where they load conditionally or stay templatable across projects. How you want to work with Claude is the exception, because it applies to every project: that belongs in your user-level CLAUDE.md, written as intent.

### 6. Stale Configuration Is Worse than No Configuration

Claude reads everything in CLAUDE.md as ground truth. When status-oriented facts drift, Claude makes decisions based on a world that no longer exists. No status leaves Claude uncertain; stale status makes Claude confidently wrong. The fix is separating what changes from what doesn't. Architecture truths (system shape, module ownership) go in CLAUDE.md. Status (phase, what's built, what's pending) needs a different home, ideally one updated automatically as the work progresses.

### 7. Automate the Mechanical, Reserve Turns for Judgment

A script is cheaper, faster, fully deterministic. An LLM's token cost is the price of discernment, worth paying only when the right action depends on reading the situation. A commit skill that examines the diff and writes an appropriate message does something `git commit -m "update"` never could. A test runner that just executes `pytest` doesn't need to be a skill.

When an agent spends half its turns running boilerplate that could be a script, that's three costs at once: its attention splits (clarity loss), mechanical output fills its context (quality loss), and the turns are spend that bought no judgment (cost). The best skills *use* scripts for their mechanical steps and reserve LLM attention for the judgment parts. Clarity, quality, and cost all point the same direction.

---

## II. Rules and Boundaries

### 8. Choose the Failure You Can Afford

A boundary you rely on is held in place by a mechanism, a convention, or a judgment, and each fails differently.

A mechanism, such as a hook, a file permission, or a withheld tool, holds even against an agent set on finishing its task. It fails by holding where it shouldn't: it can't weigh a case, so it stops an action that should go ahead as firmly as one that shouldn't. A convention, a written norm agents usually follow, holds until an agent has a reason to break it. A judgment, whether auto mode's safety check or an agent weighing the call itself, holds only as well as it reads each case. It can let through a risky action that looks routine, or refuse one that's fine.

So pick the boundary by what's at stake. What must never happen needs a mechanism, whereas a convention or a judgment is enough where a mistake can be caught and undone. But check each mechanism against what an agent can reach and what it actually matches: branch protection means little if the agent can read a token that turns it off.

### 9. Coaching Beats Silent Blocking

A hook that blocks an action decides only that the action doesn't happen. What the agent does next is still its own judgment, and a silent block gives that judgment nothing to work with. Claude is trained to deliver, so a silent block on a raw `git commit` sends the agent looking for a different path: staging manually, trying alternate syntax, eventually committing by a route the hook never anticipated, so the block fails at the one thing it was for. "Blocked: commits go through /commit, which examines the diff and follows project conventions" names the intended path, and the agent takes it without trial and error. Where no intended path exists, the reason does the coaching: "Blocked: force-pushing rewrites history others have already pulled" closes the whole class, so the agent stops and asks instead of trying `--force-with-lease`. The block is still deterministic; the coaching just makes it useful.

### 10. Guard the Cliffs, Not the Road

**If failure is detectable and recoverable, permissiveness is preferred. If failure is irreversible, deny by default.**

Permissiveness buys two things: visibility and adaptability. Mistakes are evidence. An agent that modifies files it shouldn't shows you the pattern to fix structurally, which a tight constraint would have hidden. And capable models bring judgment to edge cases the rules didn't anticipate, find better paths, recover from surprises, but only when they have room to do so. Constraints have costs that compound as models get more capable; the more able the agent, the more you forfeit by hemming it in.

The cliffs, such as `git push --force`, get explicit denies because they can't be undone. Name the cliffs in your own work, the few actions nothing can take back, and deny exactly those. Keep the denies that narrow: a broad deny overrides auto mode's safety check even where it would rightly allow an action, for example an agent clearing the scratch files it made. But a deny rule matches the command as Claude usually writes it, not every way of writing it: a deny on `git push --force` doesn't stop `git -C . push --force`. So back each cliff with something that holds however the command is written, such as branch protection on the remote, or sandboxing for files. Guard the cliffs. Everything else, you let run, watch, and fix what the watching shows you.

### 11. Work With the Grain

Configuration can direct what Claude attends to; it doesn't reliably override what training made reflexive. A habit that comes from training acts on the message in front of Claude, and it outweighs instructions loaded at the start of the session. This is why a failure can persist while a plain instruction against it is loaded.

Don't fight it with more rules. Claude has its own way of doing things, and letting it stand is usually cheaper than contradicting it, so step in only where it's causing a problem. Where a habit does get in the way, find the path where it does the work for you. Claude's pull to produce something is strong, so give it the right thing to produce. A CLAUDE.md line telling Claude to push back when it disagrees loses to its pull toward agreement. Asking "what's wrong with this plan?" uses the pull instead: objections become the thing to produce, and Claude finds them.

### 12. Carry the Intent

An instruction without its reason gets followed even after following it stops making sense, because the receiver has no way to tell. That receiver might be a subagent, or a later session reading your rules. Give it the reason along with the work, and it can notice when doing what it was told would defeat what you wanted, and say so instead of carrying on.

Every rule should carry its reason, the firm ones included. For most rules, the reason lets the agent set the rule aside when following it would work against its purpose. Without it, a provisional "keep it simple" gets read as a ban on frameworks, and a word limit gets kept at the cost of the content. For a rule against something that can't be undone, such as force-pushing over shared history, the reason works the other way. It says why there are no exceptions, which makes the rule harder to argue around, not easier. And it lets the agent apply the rule to cases the wording didn't name.

### 13. Write Rules After Mistakes, Not Before

A rule written after a mistake is a record of an observed failure; a rule written before one is a guess, and Claude's defaults are strong enough that most guessed failures never arrive. Speculative rules are how a configuration bloats: each looks prudent in isolation, none can be checked against anything that actually happened, and together they dilute the rules that earn their keep. A rule born from a real mistake has what a guessed one lacks: evidence it's needed, a concrete behavior to watch for recurrence, and a clear condition for retiring it when newer models stop making the mistake.

So wait for the failure, then fix it where it belongs. A failure of behavior usually means the agent was missing something: why you want it done a certain way, or how you use what it hands you. Tell it that, instead of writing a rule against what it did. A problem that recurs after the agent has been told why, such as editing the tests it's meant to pass, needs a mechanism: a hook, or a tool withheld. Adding more instructions where instructions have already failed is the most common mistake. With the irreversible guarded up front, waiting is safe: the mistakes you wait for are the recoverable kind, and a recoverable mistake is cheap evidence.

Write a rule only if you can state its reason for being. If the reason won't come clearly, the failure isn't understood yet. If it comes clearly, it answers the rest: whether a rule is needed at all, how far it should reach, and where it belongs.

### 14. Concrete Rules Are Greppable Rules

If a rule about the code has to hold, write it so a diff can check it. "No sqlite3 imports outside db.py and test files" passes: a hook can grep for it. "Use modular architecture" fails: no diff can show whether it held. If you can't describe a grep command or point to a specific import to check, the rule isn't concrete enough to hold on its own. That doesn't make it a bad rule. It makes it a judgment, and it holds only as well as the review that reads it. When a rule can be checked by a script, let a script check it, and save the review for the rules that need judgment.

---

## III. Delegation

### 15. Settle the Spec, Then Get Out of the Way

The human's attention is the scarcest resource in the work, and every question spends it. Spend it up front. Before the build starts, Claude should raise the questions whose answers change the outcome, each with its own lean. Then it should finish without you. Decisions found along the way are Claude's: make the best call, record it as Claude's, keep it easy to change. A thing built on a wrong guess beats a thing not started. It stops only for what needs your authority: something irreversible or outward-facing, or a change to what was agreed.

The fix is never to suppress questions; it is to move them earlier. A question answered in planning costs one exchange; the same question surfacing mid-build costs a stop, a redo, and whatever was already built on the wrong assumption. Plan in the fullest detail the task allows. A thorough plan is what keeps the build from stalling, not the freedom to stop and ask. A question mid-build is a sign that planning left something unresolved: a criterion left vague, or a decision that should have been scheduled as a checkpoint.

### 16. Define Done, or Claude Will

Claude fills gaps well, so a missing definition of done never stalls the work. The agent supplies its own. It decides which tests count, what the PR includes, what "passing" means, and ships against that. Plausible, confident, and not yours. A fuller description won't fix it: prose criteria get quietly narrowed to fit whatever got built, and the narrowing reads as success. A check can't be narrowed after the fact. It clears the bar you set or it doesn't. Wherever you can, encode done as a test, a check, a CI gate the agent has to turn green; make it prove done, not claim done.

Not every criterion can be a test. Where it can't, it still has to be checkable, because a vague criterion makes every later step guess, and guessing compounds. Every criterion needs a way to be verified, the strongest available:

- **Testable**: a machine verifies it automatically, as a test assertion. The default.
- **Observable**: someone other than the builder, a person or a separate agent, verifies it after the fact by running a command or reading output. For what no test can express.

And every criterion, however it's verified, must be:

- **Bounded**: scope is clear
- **Unambiguous**: two reasonable agents wouldn't disagree

Everything else you configure raises the probability of good work; a definition of done you can check confirms it.

### 17. Report the Workaround, and Know When to Quit

Claude is trained to deliver. When something fails, it would rather adapt than stop and report, and it can almost always find a workaround, which is exactly the problem. Asked to build X with Y, if Y is broken, a tragically helpful agent silently scopes to "X without Y" and delivers it as a success. Every check on X passes, and nothing checks that Y was used. When the adaptation is silent, nobody knows anything went wrong, and a failure you could have course-corrected becomes one you never see.

Adaptation isn't the problem; silent adaptation is. An agent that reports "I expected X, found Y, adjusted by doing Z" or "I tried X, it didn't work because Y" is doing the work as designed; reporting deviations *is* part of the work, not overhead. Finishing without you still means telling you where it departed from the plan, and the longer work runs on its own, the more that matters.

The discipline isn't recognizing when the agent *can't* push through; it's establishing when it *shouldn't*. When a workaround would change the deliverable's identity, silently reduce scope, or paper over a problem the user needs to see, the right move is to stop and report. When an action is blocked, a workaround is the same mistake: either the block is wrong and should be changed, or it's right and the action shouldn't happen that way, and going around it settles neither. If the agent stops where going on would change what was agreed, the decision is still yours. If it finishes anyway, it has changed the goal without you.

### 18. The Human Is for Decisions, Not Mechanical Approval

The high-value human work is planning, scoping, and deciding when work is ready. With autonomous execution available, the human's role is increasingly checkpoint-shaped: verifying outputs, approving promotion, answering scoping questions, not approving routine tool calls in real time. Structural enforcement (deny rules, scoped tools, hooks, sandboxing) and auto mode's classifier handle the safety layer, so attention stays on decisions only a human can make. `bypassPermissions` isn't the answer for getting out of the way; tightening the structure is.

The same holds in the other direction. Each time an agent hands the human something it could have handled (an approval already given, a step it could have taken, a command to run by hand), it spends attention on mechanics. Those handoffs should be rare. When they aren't, the boundaries are drawn wrong: set them so agents can work safely without routing through you.

---

## IV. Multi-Agent Work

### 19. Specialize When Incentives Diverge

An agent doing both build and evaluation has incentive to grade its own work generously, especially when the alternative is starting over. The agent that builds optimizes for shipping; the one that evaluates optimizes for catching. Combine them and you get the average of the two pressures. Separation isolates the pressures so each agent is judged on what it's actually built to do. The principle generalizes: split agents wherever combining roles would produce a conflict no one can audit, because the compromise happens inside the agent's reasoning, not in any artifact a later check can inspect.

### 20. The Strongest Rule Is a Withheld Tool

A subagent meant to hold work to a standard, with no Write, Edit, Bash, or Agent, can't be talked into a quick fix mid-review. A session meant to coordinate, left only the Agent tool, can't "just handle it itself" and go around the subagents, skills, and workflow scripts the work is meant to pass through. Behavioral separation enforced by instruction is a suggestion; behavioral separation enforced by tool configuration is a constraint. And an agent that can't bypass the intended workflow can't paper over a problem: the problem has to be reported so the fix can be made where it belongs.

### 21. Each Handoff Is a Filter

A handoff compresses what the previous agent saw into what they returned: the next agent gets the output, not the reasoning. That's often the point. A subagent mines logs and hands back the finding; another trims library docs to what matters. The compression *is* the value. But the same mechanism misused can drop signal. A coder hands off to an evaluator without conveying why an approach was chosen, and the evaluator can't tell intentional choice from oversight.

Place each boundary where its filter drops noise to amplify signal. The failure runs in both directions: too few agents and conflicting roles end up in one agent, where one quietly gives way to the other; too many handoffs in a chain and signal degrades, because no filter is perfect and there are only so many natural points where filtering helps. Each handoff also pays costs in spawn overhead and re-orientation. The right granularity is the fewest handoffs that give you the separations you actually need. Add an agent when planning is its own judgment-heavy step, or when "did the build pass?" is a separable question from "is the work good?"

### 22. Pass Evidence, Not Verdicts

When you ask an agent to check work, how you ask decides what it finds. "Check that this fix works" asks it to confirm, and it usually will. "Find what this fix breaks" asks it to look. You rarely tell a reviewer what to conclude outright, but you influence it in the shape of the request, or in a summary of what you believe sent ahead of the diff. Hand a reviewing agent the evidence and the criteria, and ask what's wrong. A review that only confirms looks exactly like one that found nothing.

---

## V. Maintenance

### 23. Memory Has Hidden Costs

Memory writes itself, accruing as Claude works, and nothing corrects a claim that stops being true. Every other piece of configuration changes only when you change it. A stale memory may override the instruction you deliberately wrote, and because most of it is read only when Claude judges it relevant, the interference can be intermittent: the hardest kind to catch, because it won't reproduce on demand.

If the upkeep outweighs the gain for how you work, turning memory off is legitimate: `autoMemoryEnabled: false` in a project's settings, or `/memory` to turn it off by default. If you keep it, have it audited regularly: Claude Code prompts Claude to trim the index when it grows too long, but nothing checks whether what's in it is still true. Ask Claude, or a skill, to check each memory against the project as it is now.

### 24. Measure What Loads

Everything that loads into a session has a cost you can measure: `/context` shows what loads and how much. For what's invoked, use can be measured too: `/skill-doctor` shows what each skill costs and how often it gets used, and `/doctor` flags the skills, MCP servers, and plugins that sit unused. A component you pay for every session and never invoke is the easiest to cut.

### 25. Re-tune as the Model Improves

Every guardrail is written against a specific failure of a specific model, and what's underneath keeps changing: each model generation absorbs judgment its predecessor needed scaffolding for, and each harness release builds in what you once built by hand. A constraint that earned its keep against one model's mistakes can be dead weight against its successor's: the mistake that justified a rule stops happening, the rule stays, and it is now calibrated to a model that no longer exists. So re-audit the guardrails on every model upgrade: which mistakes does it no longer make, and which constraints now cost more than they prevent? `/doctor prompt-audit` does much of the work, flagging instructions written for older models. A configuration that only ever grows is one nobody has re-audited against the model they actually have.

---

*Feedback and corrections welcome via [issues](https://github.com/daedahl/claude-code-principles/issues).*

*v2.1 · © Dave Figueroa · [CC BY 4.0](LICENSE)*
