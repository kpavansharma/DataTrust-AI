# DataTrust.AI - Quick Reference Guide

## Component Overview

| Component | Purpose | Key Features |
|-----------|---------|--------------|
| **Extension Panel** | Main container | Dashboard connection, layout management, chat integration |
| **Trust Score Widget** | Data quality scoring | Multi-factor scoring, historical trends, visual indicators |
| **AI Summary Panel** | AI-powered insights | KPI explanations, trend analysis, recommendations |
| **Anomaly Detector** | Data anomaly detection | Statistical outliers, pattern breaks, threshold violations |
| **Semantic Model** | Data model generation | AI-powered relationships, multiple export formats |
| **Time Machine** | Historical analysis | Time-based exploration, trend analysis, comparisons |
| **Inspector** | Deep data analysis | Quality metrics, performance analysis, schema validation |
| **Chat Assistant** | AI conversation | Natural language queries, contextual help |
| **Slack Integration** | Collaboration | Share insights, automated notifications |

## Quick Actions

### Essential Commands
- **Refresh Data**: Click refresh icon in dashboard info panel
- **Switch Dashboard**: Use dropdown in dashboard info section
- **Toggle Chat**: Click chat icon in bottom-right corner
- **Generate Model**: Click "Generate Semantic Model" in Semantic Model panel
- **Export Data**: Use export buttons in various panels

### Keyboard Shortcuts
- `Ctrl + R`: Refresh all data
- `Ctrl + ?`: Toggle chat assistant
- `Ctrl + Shift + D`: Toggle debug mode
- `Esc`: Close any open modal or popup

## Status Indicators

| Indicator | Meaning |
|-----------|---------|
| 🟢 Connected | Tableau data is live and updating |
| 🟡 Fallback Mode | Using sample data (no Tableau connection) |
| 🔴 Error | Component has encountered an error |
| 🔄 Loading | Data is being processed or updated |

## Trust Score Ranges

| Score | Quality Level | Description |
|-------|---------------|-------------|
| 90-100 | Excellent | High quality, reliable data |
| 75-89 | Good | Generally reliable with minor issues |
| 60-74 | Fair | Moderate quality, some concerns |
| 0-59 | Poor | Significant quality issues |

## Common Tasks

### 1. View Data Quality
1. Look at Trust Score Widget (top-left)
2. Check color coding: Green = Good, Yellow = Fair, Red = Poor
3. Click on score for detailed breakdown

### 2. Get AI Insights
1. View AI Summary Panel for automatic insights
2. Click any KPI number for detailed explanation
3. Use Chat Assistant for specific questions

### 3. Detect Anomalies
1. Check Anomaly Detector panel for highlighted issues
2. Red indicators show potential problems
3. Click anomalies for AI-powered explanations

### 4. Generate Data Model
1. Go to Semantic Model panel
2. Click "Generate Semantic Model with AI"
3. Review generated entities and relationships
4. Export in desired format (SQL, Tableau, etc.)

### 5. Troubleshoot Issues
1. Check status indicators in header
2. Use Inspector panel for detailed analysis
3. Review browser console for technical errors
4. Use Chat Assistant for help

## Export Formats

| Format | Use Case | Location |
|--------|----------|----------|
| **SQL DDL** | Database schema creation | Semantic Model panel |
| **Tableau TDS** | Tableau data source | Semantic Model panel |
| **JSON** | API integration | Various panels |
| **CSV** | Spreadsheet analysis | Inspector panel |
| **PDF Report** | Sharing insights | AI Summary panel |

## Error Resolution

### "Model Generation Error"
- Check data connectivity
- Verify dashboard has data
- Try refreshing dashboard data
- Check browser console for details

### "Connection Failed"
- Verify Tableau Extension is properly loaded
- Check network connectivity
- Restart Tableau dashboard
- Contact administrator if persistent

### "Invalid Data Format"
- Ensure dashboard has proper data structure
- Check for required fields
- Verify data types are consistent
- Use Inspector panel to validate

## Support Resources

- **View Documentation**: Left-bottom button opens full guide
- **Report Issue**: Left-bottom button opens GitHub issues
- **Chat Assistant**: AI-powered help available 24/7
- **Debug Mode**: Add `?debug=true` to URL for detailed logging

## Tips for Best Performance

1. **Regular Refresh**: Enable auto-refresh for live data
2. **Clean Data**: Better data quality = better insights
3. **Use Filters**: Filter large datasets for faster processing
4. **Monitor Trust Scores**: Keep scores above 75 for reliable analysis
5. **Export Regularly**: Save important models and insights

## Version Information

- **Current Version**: 3.0.0
- **Platform**: Salesforce Lightning Web Components
- **AI Architecture**: Hybrid (Claude + Local Models)
- **Update Frequency**: Real-time with Tableau data changes

---

*For detailed information, see the [Comprehensive Component Guide](COMPREHENSIVE_COMPONENT_GUIDE.md)*