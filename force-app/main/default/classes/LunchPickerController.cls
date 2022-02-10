public class LunchPickerController {

	public class DinerNotFoundException extends Exception {
	}
	public class RestaurantNotFoundException extends Exception {
	}
	public class MultipleRestaurantsFoundException extends Exception {
	}

	// TODO: Only really need to know who dislikes a restaurant. If not disliked, it implies
	// that the person is neutral or likes it, which are means it's good enough to eat at.
	// Need to gather real data for this to work, though, which is mildly inconvenient.

	private static final List<Restaurant__c> ALL_RESTAURANTS =
			LunchPickerQueryService.queryAllRestaurants();

	public List<Restaurant__c> restaurants {get; set;}
	public List<Restaurant__c> suggestions {get; set;}
	public String suggestionName {get; set;}
	public String dinerName {get; set;}
	public String diners {get; set;}
	public Restaurant__c decision {get; set;}
	public Boolean isFiltered;
	private static final Id PUBLIC_CALENDAR_ID = '0231U000000Cwop';
	private static final Id LUNCH_PICKER_ID = [SELECT Id FROM User WHERE Name LIKE 'Lunch Picker%'].Id;
	private static final List<String> URSA_MAJOR_TEAMMATES = new List<String> {
			'Kyle Blair', 'Wesley Springer', 'Jordan Michael'
	};
	private static final String FORMATTED_SEMICOLON = '; ';

	public LunchPickerController() {
		restaurants = ALL_RESTAURANTS;
		diners = '';
		dinerName = '';
		decision = new Restaurant__c();
		suggestions = new List<Restaurant__c>();
		suggestionName = '';
		isFiltered = false;
	}

	public void addDiner() {
		// try/catch is really unnecessary now that diners are buttons. But just in case...
		try {
			addDiner(dinerName);
			filterRestaurantsByLiked();
			clearDinerName();
		} catch (DinerNotFoundException e) {
			e.setMessage('dInEr NoT fOuND');
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage());
			ApexPages.addMessage(msg);
		}

	}

	public void addDiner(String name) {
		diners += name + FORMATTED_SEMICOLON;
	}

	public void filterRestaurantsByLiked() {
		LunchPickerQueryService.queryRestaurantsByLiked(diners, this);
	}

	public void filterNonexistentWaitRestaurants() {
		queryRestaurantsByWaitTime('Nonexistent');
	}

	public void filterShortWaitRestaurants() {
		queryRestaurantsByWaitTime('Short');
	}

	public void filterLongWaitRestaurants() {
		queryRestaurantsByWaitTime('Long');
	}

	private void queryRestaurantsByWaitTime(String waitTime) {
		isFiltered = true;
		LunchPickerQueryService.dynamicRestaurantQuery('Wait_Time__c', waitTime, this);
	}

	public void filterCheapRestaurants() {
		queryRestaurantsByPrice('<10');
	}

	public void filterAverageRestaurants() {
		queryRestaurantsByPrice('>10');
	}

	public void filterExpensiveRestaurants() {
		queryRestaurantsByPrice('15+');
	}

	private void queryRestaurantsByPrice(String price) {
		isFiltered = true;
		LunchPickerQueryService.dynamicRestaurantQuery('Price__c', price, this);
	}

	public void addRestaurantSuggestion() {
		try {
			addRestaurantSuggestion(suggestionName);
		} catch (RestaurantNotFoundException e) {
			e.setMessage('Restaurant not found. Please make sure you spelled the name right, ' +
					'including special characters.');
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage());
			ApexPages.addMessage(msg);
		} catch (MultipleRestaurantsFoundException e) {
			e.setMessage('Multiple restaurants found on query. Keep typin\'.');
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage());
			ApexPages.addMessage(msg);
		}
	}

	private void addRestaurantSuggestion(String restaurantName) {
		List<Restaurant__c> potentialSuggestions =
				LunchPickerQueryService.queryRestaurantsByName(restaurantName);
		suggestionExceptionHandler(potentialSuggestions);
		if (String.isNotBlank(suggestionName)) {
			suggestions.add(potentialSuggestions[0]);
		}
		clearSuggestionName();
	}

	public PageReference finalizeDecision() {
		insert new List<Event> {createLunchPickerEvent(), createPublicCalendarEvent()};
		return updateRestaurant();
	}

	private Event createLunchPickerEvent() {
		Event event = createEvent(LUNCH_PICKER_ID);
		event.DurationInMinutes = 60;
		event.IsAllDayEvent = false;
		event.StartDateTime = System.now();
		return event;
	}

	private Event createPublicCalendarEvent() {
		Event event = createEvent(PUBLIC_CALENDAR_ID);
		event.IsAllDayEvent = true;
		event.ActivityDate = System.today();
		return event;
	}

	private Event createEvent(Id ownerId) {
		Event event = new Event();
		event.Subject = decision.Name;
		event.OwnerId = ownerId;
		event.Description = formatDiners() + ' went to ' + decision.Name;
		return event;
	}

	private String formatDiners() {
		if (String.isBlank(diners)) {
			return 'Some guys';
		}
		if (containsAllTeamMembers(URSA_MAJOR_TEAMMATES)) {
			formatUrsaMajorDiners();
		}
		return formatDinersForEventDescription();
	}

	private Boolean containsAllTeamMembers(List<String> teamMembers) {
		Boolean containsAll = true;
		for (String teamMember : teamMembers) {
			if (!diners.contains(teamMember)) {
				containsAll = false;
			}
		}
		return containsAll;
	}

	private void formatUrsaMajorDiners() {
		for (String teamMember : URSA_MAJOR_TEAMMATES) {
			diners = diners.remove(teamMember + ';');
		}
		diners += 'Ursa Major' + FORMATTED_SEMICOLON;
	}

	private String formatDinersForEventDescription() {
		String formatted = '';
		String copy = diners.removeEnd(FORMATTED_SEMICOLON).replaceAll(';', ',');
		if (copy.countMatches(',') == 1) {
			formatted = copy.replace(',', ' and');
		} else if (copy.countMatches(',') > 1) {
			Integer lastCommaIndex = copy.lastIndexOf(',');
			formatted = copy.substring(0, lastCommaIndex) + ' and' +
					copy.substring(lastCommaIndex + 1);
		} else {
			formatted = copy;
		}
		return formatted;
	}

	public PageReference updateRestaurant() {
		Restaurant__c toUpdate = [SELECT Id, Name FROM Restaurant__c WHERE Name = :decision.Name];
		toUpdate.Last_Visited_Date__c = Date.today();
		update toUpdate;
		return new PageReference('/' + toUpdate.Id);
	}

	private void suggestionExceptionHandler(List<Restaurant__c> potentialSuggestions) {
		if (potentialSuggestions.isEmpty()) {
			throw new RestaurantNotFoundException();
		}
		if (potentialSuggestions.size() > 1 && String.isNotBlank(suggestionName)) {
			throw new MultipleRestaurantsFoundException();
		}
	}

	public PageReference pickRestaurant() {

		if (!suggestions.isEmpty()) {
			decision.Name = suggestions.get(Math.mod((Integer)(Math.random()*100), suggestions.size())).Name;
		} else {
			if (!isFiltered) {
				restaurants = LunchPickerQueryService.queryRestaurants();
			}
			decision.Name = restaurants.get(Math.mod((Integer)(Math.random()*100), restaurants.size())).Name;
		}
		return null;
	}

	public void resetRestaurants() {
		restaurants = ALL_RESTAURANTS;
	}

	public void resetDiners() {
		diners = '';
		resetRestaurants();
	}

	public void resetSuggestions() {
		suggestions.clear();
	}

	public void clearDinerName() {
		dinerName = '';
	}

	public void clearSuggestionName() {
		suggestionName = '';
	}
}