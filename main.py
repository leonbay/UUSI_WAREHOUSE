#lopullinen versio

#requirements.txt sisältää:
#google-cloud-secret-manager
#psycopg2

#tarkistetaan onko varastossa haluttu määrä tuotetta
#tarkistetaan onko asiakkaalla jo ostoskorissa tätä tuotetta (insert jos ei ole, update jos on)
#api gatewayltä requestin mukana saadaan: (customer_id, product_id, amount) -json
#lopulta ShoppingCart tauluun: requestin kamat, (automaattisesti: serial keynä luotuu CartID)
#toiminnon yhteydessä Storage-taulusta vähenee projectID:n mukaiselta riviltä Amount
#tilauksen mukaisen määrän verran
#rollbackillä varmistus, että varastosta vähenee ainoastaan jos shopping cartiin on lisääntynyt

from google.cloud import secretmanager
from configparser import ConfigParser
import psycopg2
from datetime import datetime
import requests
 
def add_to_cart(request):
    #requestin mukana: (customer_id, product_id, amount) json
    #reques jsoniksi:
    jasoni =request.get_json()
    #jsonista tiedot muuttujiin:
    asiakas = jasoni['customer_id']
    tuote = jasoni['product_id']
    paljonko = jasoni['amount']
    
    #secretmanagerista muuttujat ip, sqluser ja salasana(pw):
    client = secretmanager.SecretManagerServiceClient()
    ip2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-ipv42/versions/latest"})
    ip = ip2.payload.data.decode("UTF-8")
    pw2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-password2/versions/latest"})
    pw = pw2.payload.data.decode("UTF-8")
    sqluser2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-user2/versions/latest"})
    sqluser = sqluser2.payload.data.decode("UTF-8")

    #tarkasta onko varastossa tuotetta pyydetty määrä:
    amount_ok, num = amount_in_storage(tuote, paljonko)

    if amount_ok == True:
        #tarkista onko asiakkaan id:llä ja tuoteid:llä jo rivi. jos on -> update, jos ei -> insert
        finds = already_in_cart(asiakas, tuote)

        if finds == True:
            #tänne koodia update amount = amount + paljonko
            SQL_5 = '''UPDATE shoppingcart SET amount = amount + %s WHERE customer_id = %s AND product_id = %s;'''
            #vähentää storagesta shopping cartiin lisätyn määrän
            SQL_6 = '''UPDATE storage SET amount = amount - %s WHERE product_id = %s 
            ;'''
            #shopping cartiin lisätään:
            data_5 = (paljonko, asiakas, tuote)
            #storagesta vähennetään:
            data_6 = (paljonko, tuote)

            conn = None
            try:
                # connect to the PostgreSQL database
                conn = psycopg2.connect(host=ip, database="piirakka", port = 5432, user=sqluser, password=pw)
                # create a new cursor
                cur = conn.cursor()
                cur.execute(SQL_5, data_5)
                cur.execute(SQL_6, data_6)
                # Commit the changes to the database
                conn.commit()
                # Close communication with the PostgreSQL database
                cur.close()
            except (Exception, psycopg2.DatabaseError) as error:
                conn.rollback()
                print(error)
                print("operation was cancelled. No changes were made to the amount in storage or to the shopping cart.")
            finally:
                if conn is not None:
                    conn.close()
        elif finds == False:
            #täällä luodaan insertillä uusi rivi tuotteelle ostoskoriin
            SQL_1 = '''INSERT INTO shoppingcart (customer_id, product_id, amount) 
            VALUES (%s, %s, %s);'''
            #vähentää storagesta shopping cartiin lisätyn määrän
            SQL_2 = '''UPDATE storage SET amount = amount - %s WHERE product_id = %s 
            ;'''
            #shopping cartiin lisätään:
            data_1 = (asiakas, tuote, paljonko)
            #storagesta vähennetään:
            data_2 = (paljonko, tuote)
            conn = None
            try:
                # connect to the PostgreSQL database
                conn = psycopg2.connect(host=ip, database="piirakka", port = 5432, user=sqluser, password=pw)
                # create a new cursor
                cur = conn.cursor()
                cur.execute(SQL_1, data_1)
                cur.execute(SQL_2, data_2)
                # Commit the changes to the database
                conn.commit()
                # Close communication with the PostgreSQL database
                cur.close()
            except (Exception, psycopg2.DatabaseError) as error:
                conn.rollback()
                print(error)
                print("operation was cancelled. No changes were made to the amount in storage or to the shopping cart.")
            finally:
                if conn is not None:
                    conn.close()
    else:
        print(f"not enought products in storage. Maximum amount to purchase at the moment is {num}")
    print("se oli siinä!") #höpömuokattava testikohta

def amount_in_storage(tuote: str, paljonko: int):
    #tarkasta onko varastossa tuotetta pyydetty määrä:
    #tee sql kysely,true jos storagessa >= ostettava määrä
    SQL_3 = '''SELECT amount FROM storage WHERE product_id = %s;'''
    data_3 = (tuote,) #lisätty pilkku

    #secretmanagerista muuttujat ip, sqluser ja salasana(pw):
    client = secretmanager.SecretManagerServiceClient()
    ip2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-ipv42/versions/latest"})
    ip = ip2.payload.data.decode("UTF-8")
    pw2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-password2/versions/latest"})
    pw = pw2.payload.data.decode("UTF-8")
    sqluser2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-user2/versions/latest"})
    sqluser = sqluser2.payload.data.decode("UTF-8")

    conn = None
    try:
        print("tuli tänne")
        # connect to the PostgreSQL database
        conn = psycopg2.connect(host=ip, database="piirakka", port = 5432, user=sqluser, password=pw)
        # create a new cursor
        cur = conn.cursor()
        # execute
        cur.execute(SQL_3, data_3)
        lista = cur.fetchall()
        print("lista on", lista)
        num = lista[0][0]
        print("num on", num)
        if paljonko <= num:
            amount_ok = True
            print("iffissä amount ok on", amount_ok)
        else:
            amount_ok = False
            print("elsessä amount ok on", amount_ok)
        # Close communication with the PostgreSQL database
        conn.commit()
        cur.close()
    except:
        print("query failed for some reason. maybe no product in storage?")
    finally:
        if conn is not None:
            conn.close()

    return amount_ok, num

def already_in_cart(asiakas, tuote):
    #tutkii onko asiakkaalla jo tämä tuote ostoskorissa
    SQL_7 = "SELECT amount FROM shoppingcart WHERE customer_id = %s AND product_id = %s;"
    data_7 = (asiakas, tuote)

    #secretmanagerista muuttujat ip, sqluser ja salasana(pw):
    client = secretmanager.SecretManagerServiceClient()
    ip2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-ipv42/versions/latest"})
    ip = ip2.payload.data.decode("UTF-8")
    pw2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-password2/versions/latest"})
    pw = pw2.payload.data.decode("UTF-8")
    sqluser2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-user2/versions/latest"})
    sqluser = sqluser2.payload.data.decode("UTF-8")

    conn = None
    try:
        # connect to the PostgreSQL database
        conn = psycopg2.connect(host=ip, database="piirakka", port = 5432, user=sqluser, password=pw)
        # create a new cursor
        cur = conn.cursor()
        # execute
        cur.execute(SQL_7, data_7)
        lista = cur.fetchall()
        num = lista[0][0]
        if num >= 0:
            is_there = True
        # Close communication with the PostgreSQL database
        cur.close()
    except:
        is_there = False
    finally:
        if conn is not None:
            conn.close()

    return is_there