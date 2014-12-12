public with sharing  class DataConvert {
	public static Long ToLong(object invalue){
		if (invalue instanceof Integer){
			return (Long)invalue;
		} else if (invalue instanceof Long){
			return (Long)invalue;
		} else if (invalue instanceof double){
			return ToLong((double)invalue);
		} else if (invalue instanceof decimal){
			return ToLong((decimal)invalue);
		} else if (invalue instanceof string){
			return ToLong((string)invalue);
		} 
		throw new DataConvertException('Invalid cast to Long');
	}
	public static Long ToLong(string invalue){
		return Long.valueOf(invalue);
	}
	public static Long ToLong(double invalue){
		return invalue.longValue();
	}
	public static Long ToLong(decimal invalue){
		return invalue.longValue();
	}
	public static Integer ToInteger(object invalue){
		if (invalue instanceof Integer){
			return (Integer)invalue;
		} else if (invalue instanceof Long){
			return ToInteger((Long)invalue);
		} else if (invalue instanceof Double){
			return ToInteger((Double)invalue);
		} else if (invalue instanceof Decimal){
			return ToInteger((Decimal)invalue);
		} else if (invalue instanceof string){
			return ToInteger((string)invalue);
		} 
		return Integer.valueof(invalue);
	}
	public static Integer ToInteger(string invalue){
		return Integer.valueOf(invalue);
	}
	public static Integer ToInteger(long invalue){
		return invalue.intValue();
	}
	public static Integer ToInteger(decimal invalue){
		return invalue.intValue();
	}
	public static Decimal ToDecimal(object invalue){
		if (invalue instanceof Integer){
			return (Decimal)invalue;
		} else if (invalue instanceof Long){
			return (Decimal)invalue;
		} else if (invalue instanceof Double){
			return (Decimal)invalue;
		} else if (invalue instanceof Decimal){
			return (Decimal)invalue;
		} else if (invalue instanceof string){
			return ToDecimal((string)invalue);
		} 
		throw new DataConvertException('Invalid cast to Decimal');
	}
	public static Decimal ToDecimal(string invalue){
		return Decimal.valueOf(invalue);
	}
	public static Double ToDouble(object invalue){
		if (invalue instanceof Integer){
			return (Double)invalue;
		} else if (invalue instanceof Long){
			return (Double)invalue;
		} else if (invalue instanceof Double){
			return (Double)invalue;
		} else if (invalue instanceof string){
			return ToDouble((string)invalue);
		} 
		return Double.valueOf(invalue);
	}
	public static Double ToDouble(string invalue){
		return Double.valueOf(invalue);
	}
	public static Double ToDouble(decimal invalue){
		return invalue.doubleValue();
	}
	
// Boolean Conversion	
	public static Boolean ToBoolean(object invalue){
		if (invalue instanceof Boolean){
			return (Boolean)invalue;
		} else if (invalue instanceof string){
			return ToBoolean((string)invalue);
		} 
		return Boolean.valueOf(invalue);
	}
	public static Boolean ToBoolean(string invalue){
		return Boolean.valueOf(invalue);
	}
	
// Date Conversion
	public static Date ToDate(object invalue){
		if (invalue instanceof date){
			return (date)invalue;
		} else if (invalue instanceof string){
			return ToDate((string)invalue);
		} else if (invalue instanceof datetime){
			return ToDate((datetime)invalue);
		}
		return Date.valueOf(invalue);
	}
	public static Date ToDate(datetime invalue){
		return invalue.Date();
	}
	public static Date ToDate(string invalue){
		return Date.parse(invalue);
	}
	public static DateTime ToDateTime(object invalue){
		if (invalue instanceof DateTime){
			return (DateTime)invalue;
		} else if (invalue instanceof string){
			return ToDateTime((string)invalue);
		} else if (invalue instanceof Date){
			return ToDateTime((Date)invalue);
		}
		return DateTime.valueOf(invalue);
	}
	public static DateTime ToDateTime(Date invalue){
		return DateTime.newinstance(invalue, Time.newinstance(0,0,0,0));
	}
	public static DateTime ToDateTime(string invalue){
		return DateTime.parse(invalue);
	}
	
	public static Time ToTime(object invalue){
		if (invalue instanceof Time){
			return (Time)invalue;
		} else if (invalue instanceof string){
			return ToTime((string) invalue);
		}
		throw new DataConvertException('Invalid cast to Time');
	}
	public static Time ToTime(string invalue){
		return DateTime.valueofGMT( '2000-1-1 ' + invalue).timeGMT();
	}

// ToString Conversions
	public static String ToString(object invalue){
		if (invalue instanceof string){
			return (string)invalue;
		} else if (invalue instanceof integer){
			return ToString((integer)invalue);
		} else if (invalue instanceof long){
			return ToString((long)invalue);
		} else if (invalue instanceof double){
			return ToString((double)invalue);
		} else if (invalue instanceof decimal){
			return ToString((decimal)invalue);
		} else if (invalue instanceof date){
			return ToString((date)invalue);
		} else if (invalue instanceof datetime){
			return ToString((datetime)invalue);
		} else if (invalue instanceof time){
			return ToString((time)invalue);
		}
		throw new DataConvertException('Invalid cast to string');
	}
	public static String ToString(integer invalue){
		return invalue.format();
	}
	public static String ToString(long invalue){
		return invalue.format();
	}
	public static String ToString(double invalue){
		return invalue.format();
	}
	public static String ToString(decimal invalue){
		return invalue.format();
	}
	public static String ToString(date invalue){
		return invalue.format();
	}
	public static String ToString(datetime invalue){
		return invalue.format();
	}
	public static String ToString(time invalue){
		return invalue.hour() + ':' + invalue.minute() + ':' + invalue.second() +
			(invalue.millisecond() != 0 ? '.' + invalue.millisecond() : '');
	}
	
	public class DataConvertException extends Exception{
	}
	
}