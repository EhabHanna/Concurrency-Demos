# Concurrency Problems Demo
This is a demo of popular concurrency problems and their solutions implemented as Swift classes.

## Dining Philosopher's problem
Consider a Table in a restaurant with 5 philosophers sitting on it, in front of each philosopher there is 1 plate of spaghetti and only 1 fork. And the rules of the restaurant are that you can only eat with 2 forks.

The solution presented here was proposed by A. S. Tanenbaum in his book, see acknowledgements.

more details about this problem can be found [here](https://en.wikipedia.org/wiki/Dining_philosophers_problem)

## Cigarette Smokers problem
Suppose a cigarette requires three ingredients, tobacco, paper and match. There are three chain smokers. Each of them has only one ingredient with infinite supply. There is an agent who has infinite supply of all three ingredients. To make a cigarette, the smoker has tobacco (resp., paper and match) must have the other two ingredients paper and match (resp., tobacco and match, and tobacco and paper). The agent and smokers share a table. The agent randomly generates two ingredients and notifies the smoker who needs these two ingredients. Once the ingredients are taken from the table, the agent supplies another two. On the other hand, each smoker waits for the agent's notification. Once it is notified, the smoker picks up the ingredients, makes a cigarette, smokes for a while, and goes back to the table waiting for his next ingredients.

The solution presented here was proposed by D. L. Parnas, see acknowledgements.

more details about this problem can be found [here](https://en.wikipedia.org/wiki/Cigarette_smokers_problem)


## Authors

* **Ehab Asaad Hanna** - [Git Hub Page](https://github.com/EhabHanna)

## Acknowledgments

* A. S. Tannenbaum - [Modern Operating Systems](https://www.amazon.com/Modern-Operating-Systems-Andrew-Tanenbaum/dp/013359162X/ref=sr_1_2/135-8446626-0686055?s=books&ie=UTF8&qid=1500610484&sr=1-2&refinements=p_27%3AAndrew+S.+Tanenbaum)
* D. L. Parnas - [Research Showcase @ CMU](http://repository.cmu.edu/cgi/viewcontent.cgi?article=2992&context=compsci)
