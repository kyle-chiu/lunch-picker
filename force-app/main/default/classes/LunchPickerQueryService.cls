public with sharing class LunchPickerQueryService {

	private static final String QUERY_BASE = 'SELECT Name, Wait_Time__c, Liked_By__c, ' +
			'Disliked_By__c, Price__c, Last_Visited_Date__c, Revisitability__c, ' +
			'Days_Since_Last_Visit__c FROM Restaurant__c ';
	private static final String QUERY_DISLIKED_EXCLUDES = ' Disliked_By__c EXCLUDES(:';
	private static final String QUERY_WHERE_NAME_LIKE = ' WHERE Name LIKE :';
	private static final String QUERY_REVISITABILITY = ' (((Revisitability__c = \'Whenever\') OR ' +
			'(Revisitability__c = \'High\'AND Days_Since_Last_Visit__c >= 7) OR ' +
			'(Revisitability__c = \'Medium\'AND Days_Since_Last_Visit__c >= 10) OR ' +
			'(Revisitability__c = \'Low\'AND Days_Since_Last_Visit__c >= 14)) OR ' +
			'Days_Since_Last_Visit__c = null)';
	private static final String QUERY_NOT_CLOSED = ' Closed__c = false';
	private static final String QUERY_ORDER = ' ORDER BY Name ASC';
	private static String query = '';

	@AuraEnabled
	public static List<Restaurant__c> queryAllRestaurants() {
		query = QUERY_BASE + ' WHERE' + QUERY_NOT_CLOSED + QUERY_ORDER;
		return Database.query(query);
	}

	public static List<Restaurant__c> queryRestaurants() {
		query = QUERY_BASE + 'WHERE' + QUERY_REVISITABILITY + ' AND' + QUERY_NOT_CLOSED + QUERY_ORDER;
		return Database.query(query);
	}

	public static List<Restaurant__c> queryRestaurantsByName(String restaurantName) {
		String formattedName = restaurantName + '%';
		query = QUERY_BASE + QUERY_WHERE_NAME_LIKE + 'formattedName' + ' AND' + QUERY_NOT_CLOSED +
				QUERY_ORDER;
		return Database.query(query);
	}

	public static void queryRestaurantsByLiked(String names, LunchPickerController lpc) {
		names = lpc.diners.removeEnd(';');
		lpc.isFiltered = true;
		query = QUERY_BASE + 'WHERE' + QUERY_DISLIKED_EXCLUDES + 'names) AND' +
				QUERY_REVISITABILITY + ' AND' + QUERY_NOT_CLOSED + QUERY_ORDER;
		lpc.restaurants = Database.query(query);
	}

	public static void dynamicRestaurantQuery(String fieldApiName, String fieldValue, LunchPickerController lpc) {
		String names = lpc.diners.removeEnd(';');
		query = QUERY_BASE + 'WHERE ' + fieldApiName + '= :fieldValue AND' + QUERY_REVISITABILITY +
				' AND' + QUERY_NOT_CLOSED;
		if (String.isNotBlank(lpc.diners)) {
			query += ' AND' + QUERY_DISLIKED_EXCLUDES + 'names)';
		}
		query += QUERY_ORDER;
		lpc.restaurants = Database.query(query);
	}
}