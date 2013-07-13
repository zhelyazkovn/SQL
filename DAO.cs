using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NorthwindHW.Data;

namespace NorthwindHW.Client
{
    public static class DAOManipulation
    {
        public static NORTHWNDEntities db = new NORTHWNDEntities();

        public static void InsertCustomer(string customerID, string companyName, string city)
        {
            using (db)
            {
                var newCustomer = new Customer
                {
                    CustomerID = customerID,
                    CompanyName = companyName,
                    ContactName = null,
                    ContactTitle = null,
                    Address = null,
                    City = city,
                    Region = null,
                    PostalCode = null,
                    Country = null,
                    Phone = null,
                    Fax = null
                };

                db.Customers.Add(newCustomer);
                db.SaveChanges();
            }
        }

        public static void DeleteCustomer(string customerID)
        {
            using (db)
            {
                var customerToRemove = db.Customers.Find(customerID);

                db.Customers.Remove(customerToRemove);
                db.SaveChanges();
            }
        }

        public static void ModifyCustomer(string customerID, string companyName, string city)
        {
            using (db)
            {
                var customerToModify = db.Customers.Find(customerID);
                customerToModify.CompanyName = companyName;
                customerToModify.City = city;
                db.SaveChanges();
            }
        }
    }
}
