/*
   Query 1: Over how many years was the unemployment data collected?
   ======================================
*/

// lists out the years with recorded data
db.unemployment.distinct("Year") 

// outputs the quantity of years 
db.unemployment.distinct("Year").length

/*
   Query 2: How many states were reported on in this dataset?
   ======================================
*/

// lists out the states with recorded data
db.unemployment.distinct("State") 

// outputs the quantity of states 
db.unemployment.distinct("State").length

/*
   Query 3: What does this query compute?
            db.unemployment.find({Rate : {$lt: 1.0}}).count()
   ======================================
*/

//outputs the number of instances that a state
//county had an unemployment rate less than 1% (during any of the recorded months and years). 


/*
   Query 4: Find all counties with unemployment rate higher than 10%
   ======================================
*/

db.unemployment.find({Rate: {$gt: 10.0}},{County:1, State: 1, Rate: 1, _id:0})


/*
   Query 5: Calculate the average unemployment rate across all states.
   ======================================
*/

[
  {
    $group:
      /**
       * _id: null.
       * AverageRate: computed average unemployment rate.
       */
      {
        _id: null,
        AverageRate: {
          $avg: "$Rate"
        }
      }
  },
  {
    $project:
      /**
       * include AverageRate, exclude _id.
       */
      {
        _id: 0,
        AverageRate: 1
      }
  }
]


/*
   Query 6: Find all counties with an unemployment rate between 5% and 8%.
   ======================================
*/

[
  {
    $match:
      /**
       * filter Rates between 5 and 8%.
       */
      {
        Rate: {
          $gt: 5.0,
          $lt: 8.0
        }
      }
  },
  {
    $group:
      /**
       * _id: The id of the group - County field.
       */
      {
        _id: "$County"
      }
  },
  {
    $project:
      /**
       * Fields to include: County.
       */
      {
        County: "$_id",
        _id: 0
      }
  }
]



/*
   Query 7: Find the state with the highest unemployment rate. Hint. Use { $limit: 1 }
   ======================================
*/

[
  {
    $project:
      /**
       * include State and Rate fields, exclude _id.
       */
      {
        State: 1,
        Rate: 1,
        _id: 0
      }
  },
  {
    $sort:
      /**
       * Sort Rate in ascending order.
       */
      {
        Rate: -1
      }
  },
  {
    $limit:
      /**
       * Take top document (highest unemployment rate).
       */
      1
  }
]



/*
   Query 8: Count how many counties have an unemployment rate above 5%.

   ======================================
*/



[
  {
    $match:
      /**
  * query: matches with instances of 
  unemployment rates over 5.0%.
  */
      {
        Rate: {
          $gt: 5.0
        }
      }
  },
  {
    $count:
      /**
  * Provide the field name (Rate)
  for the count.
  */
      "Rate"
  }
]


/*
   Query 9: Calculate the average unemployment rate per state by year.

   ======================================
*/

[
  {
    $group:
      /**
       * Group by state AND year. Calculate average unemployment rate by these grouped fields.
       */
      {
        _id: {
          state: "$State",
          year: "$Year"
        },
        avg_unemployment_rate: {
          $avg: "$Rate"
        }
      }
  },
  {
    $project:
      /**
       * Include - state, year, avg_unemployment_rate.
       * Exclude - _id.
       */
      {
        _id: 0,
        state: "$_id.state",
        year: "$_id.year",
        avg_unemployment_rate:
          "$avg_unemployment_rate"
      }
  }
]

/*
   Query 10: (Extra Credit) For each state, calculate the total unemployment rate across all counties (sum of all county rates).

   ======================================
*/

[
  {
    $group:
      /**
       * _id: $State.
       * total_unemployment_rate: sum of all rates of each state. 
       */
      {
        _id: "$State",
        total_unemployment_rate: {
          $sum: "$Rate"
        }
      }
  },
  {
    $project:
      /**
       * Include - total_unemployment_rate, state
       * Exclude - _id
       */
      {
        total_unemployment_rate: 1,
        _id: 0,
        state: "$_id"
      }
  }
]


/*
   Query 11: (Extra Credit) The same as Query 10 but for states with data from 2015 onward

   ======================================
*/

[
  {
    $match:
      /**
       * Matches documents with Year field in 2015 or later. 
       */
      {
        Year: {
          $gte: 2015
        }
      }
  },
  {
    $group:
      /**
       * _id: $State.
       * total_unemployment_rate: sum of all rates of each state.
       */
      {
        _id: "$State",
        total_unemployment_rate: {
          $sum: "$Rate"
        }
      }
  },
  {
    $project:
      /**
       * Include - total_unemployment_rate, state
       * Exclude - _id
       */
      {
        _id: 0,
        state: "$_id",
        total_unemployment_rate: 1
      }
  }
]
