using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NorthwindHW.Data;
using System.Globalization;

namespace NorthwindHW.Client
{
    class Program
    {
        static void Main()
        {
            //Insert
            //Console.WriteLine(DAOManipulation.InsertCustomer("NIKII", "Around the Horn", "London"));
            //Delete
            // DAOManipulation.DeleteCustomer("NIKII");
            //Modify
            // DAOManipulation.ModifyCustomer("NIKII", "Alfreds Futterkiste", "Berlin");


            //FindByOrder(1997, "Canada");
            //Console.WriteLine();
            //FindByOrder2(1997, "Canada");
            //Console.WriteLine();
            //FindByOrderUsingSQL(1997, "Canada");
            //Console.WriteLine();

            FindSales("WA", new DateTime(1997,01,01), new DateTime(1997, 06, 06));

        }

        //3.DAOManipulation Write a method that finds all customers who have orders made in 1997 and shipped to Canada.

        static void FindByOrder(int year, string country)
        {
            NORTHWNDEntities db = new NORTHWNDEntities();
            var yearDown = new DateTime(year - 1, 12, 30);
            var yearUp = new DateTime(year + 1, 01, 01);
            using (db)
            {
                var askedCustomers =
                    from c in db.Customers
                    join o in db.Orders
                    on c.CustomerID equals o.CustomerID
                    where o.OrderDate > yearDown
                        && o.OrderDate < yearUp
                        && o.ShipCountry == country
                    group c by c.CustomerID
                        into h
                    select new
                    {
                        h.Key
                    };

                int n = 1;
                foreach (var item in askedCustomers)
                {
                    Console.WriteLine(n + " " + item);
                    n++;
                }
            }
        }

        //task 3 second solution
        static void FindByOrder2(int year, string country)
        {
            NORTHWNDEntities db = new NORTHWNDEntities();
            var customersOrders = db.Orders.Where(o => o.OrderDate.Value.Year == year
                    && o.ShipCountry == country).GroupBy(o => o.Customer.CompanyName);
            foreach (var item in customersOrders)
            {
                Console.WriteLine(item.Key);
            }    
        }

        //4. Implement previous by using native SQL query and executing it through the DbContext.
        static void FindByOrderUsingSQL(int year, string country)
        {
            NORTHWNDEntities db = new NORTHWNDEntities();
            string nativeSQLQuery =
                                    "SELECT c.CustomerID " +
                                    "FROM Customers c " +
                                    "JOIN Orders o " +
                                    "ON c.CustomerID = o.CustomerID " +
                                   "WHERE YEAR(o.OrderDate) = {0} " +
                                    "AND o.ShipCountry = {1} " +
                                    "group by c.CustomerID" ;
            object[] parameters = { year, country };
            var askedCustomers = db.Database.SqlQuery<string>(nativeSQLQuery, parameters);

            foreach (var item in askedCustomers)
            {
                Console.WriteLine(item);
            }
        }

       //5. Write a method that finds all the sales by specified region and period (start / end dates).
        static void FindSales(string region, DateTime from, DateTime to)
        {
            NORTHWNDEntities db = new NORTHWNDEntities();
            var askedSales = db.Orders.Where(o => o.ShipRegion == region &&
                                                                  o.OrderDate > from &&
                                                                  o.OrderDate < to)
                                      .Select(o => new { ShipName = o.ShipName, OrderDate = o.OrderDate});

            foreach (var item in askedSales)
            {
                Console.WriteLine(item.ShipName + " - " + item.OrderDate);
            }
        }
    }
}
