from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import csv
from itertools import chain


# Windows users need to specify the path to chrome driver you just downloaded.
# You need to unzip the zipfile first and move the .exe file to any folder you want.
# driver = webdriver.Chrome(r'path\to\where\you\download\the\chromedriver.exe')
driver = webdriver.Chrome(r'C:\Data\Bootcamp\chromedriver.exe')

driver.get("https://www.zomato.com/new-york-city/top-restaurants")

#Write data to csv file
rest_info = open ('restaurant_info.csv', 'w', newline='')  
writer1 = csv.writer(rest_info)
writer1.writerow(['restaurant_name','location','cuisine'])

rest_review = open('restaurant_review_test.csv', 'w', newline='') 
writer2 = csv.writer(rest_review)
writer2.writerow(['rest_name','user_name','review_date_time','review'])	

rest_info_additional = open('restaurant_info_additional.csv', 'w', newline='') 
writer3 = csv.writer(rest_info_additional)
writer3.writerow(['address','postal_code' ,'rating', 'average_cost','weekday_hours','weekend_hours','additional_info','rest_name'])	
 


index = 1

def isPresent(path):
	try:
		element= path
		return True
	except Exception:
		return False

def is_text_present(path):
    try:
        body = driver.find_element_by_xpath(path) # find element
    except NoSuchElementException as e:
        return False
    return True

try:
	
	wait_restaurant = WebDriverWait(driver, 5)
	top_restaurants = wait_restaurant.until(EC.presence_of_all_elements_located((By.XPATH,
		'.//div[@class="row col-res-list collection_listings_container"]/div')))
	
	print (len(top_restaurants))
	print ('-' *40)
	links = [elem.get_attribute('href') for elem in driver.find_elements_by_xpath('.//div[@class="ptop0 pbot0 pl10 pr10"]/a[1]') ]  


	restaurant_info= {}
	restaurant_info_add = {}

    # loop through each restaurant and get name, address, ratings, reviews
	for restaurant in top_restaurants:
		print("Scraping restaurant number " + str(index))
		index = index + 1
		

		

		restaurant_name = restaurant.find_element_by_xpath('.//div[@class="ptop0 pbot0 pl10 pr10"]/a/div[@class="res_title zblack bold "]').text
		
			
		location = restaurant.find_element_by_xpath('.//div[@class="ptop0 pbot0 pl10 pr10"]/a/div[@class="nowrap grey-text fontsize5 ttupper"]').text
		
		cuisine = restaurant.find_element_by_xpath('.//div[@class="ptop0 pbot0 pl10 pr10"]/div[@class="nowrap grey-text"]').text
		
		
		restaurant_info['restaurant_name'] = restaurant_name
		restaurant_info['location'] = location
		restaurant_info['cuisine'] = cuisine
		writer1.writerow(restaurant_info.values())


	# get details for each restaurant

	for link in links:
		print ('opening' + link)	
		driver.get(link)

		# navigate to tab all reviews
		try:
			tabs = driver.find_element_by_xpath('//*[@id="selectors"]').find_elements_by_tag_name('a')
			#print(tabs)
			allreviews = [i for i in tabs if 'All Review' in i.text]  
			#print(allreviews)
			if allreviews[0].is_enabled():
				#print('we can see button')
				
				time.sleep(3)
				driver.execute_script("arguments[0].click();", allreviews[0])
				# tried with sending keys
				# allreviews[0].click()
				# try:
				# 	allreviews[0].send_keys(Keys.RETURN)
				# except:
				# 	allreviews[0].send_keys("keysToSend")
				# 	allreviews[0].submit()

		except Exception as e:
			print(e)
		
		

		#click on the button until all reviews are loaded
		while True:
			try:
				time.sleep(1)
				wait_button = WebDriverWait(driver, 10)	
				button = driver.find_element_by_xpath('//div[@class="load-more bold ttupper tac cursor-pointer fontsize2"]')
		
				driver.execute_script("arguments[0].click();", button)
			except:
				break
				
				
		# scrape reviews  
		wait_review = WebDriverWait(driver, 3)
		restaurant_review = {} 		
		
		
		try:
			rest_name = driver.find_element_by_xpath ('//div[@class="col-l-12"]/h1/a').text
			rating = driver.find_element_by_xpath('//div[@class="res-rating pos-relative clearfix mb5"]/div').text
			average_cost = driver.find_element_by_xpath('//div[@class="res-info-detail"]/span[2]').text
			address = driver.find_element_by_xpath('//div[@class="resinfo-icon"]').text
			postal_code = driver.find_element_by_xpath('//div[@class="resinfo-icon"]/span[2]/a').text
			weekday_hours = driver.find_element_by_xpath('//div[@class="res-week-timetable ui popup bottom left transition hidden"]/table/tbody/tr[1]/td[@class="pl10"]').text
			weekend_hours = driver.find_element_by_xpath('//div[@id="res-week-timetable"]/table/tbody/tr[6]/td[@class="pl10"]').text
			#salient_features = driver.find_element_by_xpath('.//div[@class="res-info-known-for-text mr5"]').text
			info = driver.find_elements_by_xpath('//div[@class="res-info-highlights"]/div')
			#print (len(info))
			additional_features=[]
			for i in info:
				elem = i.find_element_by_xpath('.//div[@class="res-info-feature-text" ]').text
				additional_features.append(elem)
			#print (additional_features)	
		

			restaurant_info_add['address'] = address
			restaurant_info_add['postal_code'] = postal_code
			restaurant_info_add['rating']= rating
			restaurant_info_add['average_cost'] = average_cost
			restaurant_info_add['weekday_hours'] = weekday_hours
			restaurant_info_add['weekend_hours'] = weekend_hours
			#restaurant_review['features'] = salient_features
			restaurant_info_add['additional_features'] = additional_features
			restaurant_info_add['rest_name'] = rest_name


			writer3.writerow(restaurant_info_add.values())
			
		except Exception as e:
			print(e)
			pass



		reviews = driver.find_elements_by_xpath('//div[@class= "  ui segments res-review-body res-review clearfix js-activity-root mbti   item-to-hide-parent stupendousact"]')

		print (len(reviews))

		for review in reviews:
			try:
				user_name = review.find_element_by_xpath('.//div[1][@class="header nowrap ui left"]/a').text
				user_review = review.find_element_by_xpath('.//div[@class="ui segment clearfix  brtop "]/div[3]').text
				rest_name = driver.find_element_by_xpath ('//div[@class="col-l-12"]/h1/a').text
				review_datetime = review.find_element_by_xpath('.//div[@class="fs12px pbot0 clearfix"]/a').text
				
				
				try:
					print ("writing to dictionary")
					
					restaurant_review['rest_name']= rest_name
					restaurant_review['user_name'] = user_name
					restaurant_review['review_datetime'] = review_datetime
					#restaurant_review['user_rating'] = user_ratings2
					restaurant_review['review'] = user_review

					print("writing to file")
					writer2.writerow(restaurant_review.values())
					print ("written to file completed")
				except Exception as e:
					print (e)

	
			
			except Exception as e:
				#print (e)
				pass
			
			

		#commented all the print statements used for testing		
		#print (weekday_hours)
		#print (weekend_hours)
		
		#print (rest_name)
		
		#print (rating)
		#print (average_cost)
		#print (address)
		#print (postal_code)
		
				
	driver.back() 
					
except Exception as e:
	print(e)
	driver.close()
	break
	
