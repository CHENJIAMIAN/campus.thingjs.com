/**
 * Some methods of 2D Math.
 * And this does not depend on any other library.
 * Point type use {x: number, y: number}.
 * @author shawn.xie
 */

(function (win) {

    /**
     * Distance between point and point.
     * @param {point} pointA - Point A.
     * @param {point} pointB - Point B.
     * @return {number}
     */
    function pointToPointDistance(pointA, pointB) {
        let a = pointA.x - pointB.x;
        let b = pointA.y - pointB.y;
        return Math.sqrt(a * a + b * b);
    }
    win.pointToPointDistance = pointToPointDistance;

    /**
     * Distance between point and line.
     * @param {point} pointA - Line point A.
     * @param {point} pointB - Line point B.
     * @param {point} point - Test point.
     * @return {number}
     */
    function pointToLineDistance(pointA, pointB, point) {
        let k, b, d;

        if (pointB.x === pointA.x) {
            k = Infinity;
            b = pointB.x;
        } else {
            k = (pointB.y - pointA.y) / (pointB.x - pointA.x);
            b = pointB.y - k * pointB.x;
        }

        if (k !== Infinity) {
            d = Math.abs(k * point.x - point.y + b) / Math.sqrt(k * k + 1);
        } else {
            d = Math.abs(b - point.x);
        }

        return d;
    }
    win.pointToLineDistance = pointToLineDistance;

    /**
     * If the projection of the point to the segment is inside.
     * @param {point} pointA - Line point A.
     * @param {point} pointB - Line point B.
     * @param {point} point - Test point.
     * @param {boolean} [containsEndpoint=true] - Default contains endpoint.
     * @return {boolean}
     */
    function projectionInside(pointA, pointB, point, containsEndpoint) {
        containsEndpoint = (containsEndpoint !== undefined) ? containsEndpoint : true;

        if (pointA.x === pointB.x && pointA.y === pointB.y) {
            if (containsEndpoint) {
                return point.x === pointA.x && point.y === pointA.y;
            } else {
                return false;
            }
        }

        point = projectPointToLineSegment(pointA, pointB, point);

        if (containsEndpoint) {
            return point.y >= Math.min(pointB.y, pointA.y) && Math.max(pointB.y, pointA.y) >= point.y &&
                point.x >= Math.min(pointB.x, pointA.x) && Math.max(pointB.x, pointA.x) >= point.x;
        } else {
            return (point.y > Math.min(pointB.y, pointA.y) && Math.max(pointB.y, pointA.y) > point.y &&
                point.x > Math.min(pointB.x, pointA.x) && Math.max(pointB.x, pointA.x) > point.x) ||
                (point.x === pointB.x && pointB.x === pointA.x && point.y > Math.min(pointB.y, pointA.y) && Math.max(pointB.y, pointA.y) > point.y) ||
                (point.y === pointB.y && pointB.y === pointA.y && point.x > Math.min(pointB.x, pointA.x) && Math.max(pointB.x, pointA.x) > point.x);
        }

    }
    win.projectionInside = projectionInside;

    /**
     * Get projection point by Line Segment and origin point.
     * @param {point} pointA - Line Segment point A.
     * @param {point} pointB - Line Segment point B.
     * @param {point} point - Test point.
     * @return {point}
     */
    function projectPointToLineSegment(pointA, pointB, point) {
        let k, b;

        // pointB.x === pointA.x
        if (Math.abs(pointB.x - pointA.x) <= 0.001) {
            k = "no";
            b = pointB.x;
        } else {
            k = (pointB.y - pointA.y) / (pointB.x - pointA.x);
            b = pointB.y - k * pointB.x;
        }

        let calx, caly;

        if (k !== "no") {
            if (k !== 0) {
                calx = ((point.y + point.x / k) - b) * k / (k * k + 1);
                caly = k * calx + b;
            } else {
                calx = point.x;
                caly = pointB.y;
            }
        } else {
            calx = b;
            caly = point.y;
        }

        return { x: calx, y: caly };
    }
    win.projectPointToLineSegment = projectPointToLineSegment;

    /**
     * Get projection point by line and origin point.
     * @param {point} K - Line slope.
     * @param {point} B - Line intercept.
     * @param {point} point - Test point.
     * @return {point}
     */
    function projectPointToLine(K, B, point) {
        let calx, caly;

        if (K !== "no") {
            if (K !== 0) {
                calx = ((point.y + point.x / K) - B) * K / (K * K + 1);
                caly = K * calx + B;
            } else {
                calx = point.x;
                caly = B;
            }
        } else {
            calx = B;
            caly = point.y;
        }

        return { x: calx, y: caly };
    }
    win.projectPointToLine = projectPointToLine;

    /**
     * If point in Line.
     * @param {point} pointA - Line point A.
     * @param {point} pointB - Line point B.
     * @param {point} point - Test point.
     * @param {number} [deviation=0.001] The deviation.
     * @return {boolean}
     */
    function pointInLine(pointA, pointB, point, deviation) {
        deviation = (deviation !== undefined) ? deviation : 0.001;
        return pointToLineDistance(pointA, pointB, point) < deviation;
    }
    win.pointInLine = pointInLine;

    /** 
     * If point in Line Segment. 
     * @param {point} pointA - Line point A.
     * @param {point} pointB - Line point B.
     * @param {point} point - Test point.
     * @param {number} [deviation=0.001] The deviation.
     * @param {boolean} [containsEndpoint=true] - Default contains endpoint.
     * @return {boolean}
     */
    function pointInLineSegment(pointA, pointB, point, deviation, containsEndpoint) {
        deviation = (deviation !== undefined) ? deviation : 0.001;
        containsEndpoint = (containsEndpoint !== undefined) ? containsEndpoint : true;

        if ((point.x == pointA.x && point.y == pointA.y) || (point.x == pointB.x && point.y == pointB.y)) {
            return containsEndpoint;
        }

        return (pointToLineDistance(pointA, pointB, point) < deviation) && projectionInside(pointA, pointB, point, containsEndpoint);
    }
    win.pointInLineSegment = pointInLineSegment;

    /** 
     * If two Line Segment intersect. 
     * Before calling this, make sure the two line segments not Collinear.
     * Refference: http://fins.iteye.com/blog/1522259
     * @param {point} a - Line1 point start.
     * @param {point} b - Line1 point end.
     * @param {point} c - Line2 point start.
     * @param {point} d - Line2 point end.
     * @param {number} [deviation=0.001] The deviation for point in line segment.
     * @return {boolean}
     */
    function intersectLineSegments(a, b, c, d, deviation) {
        deviation = (deviation !== undefined) ? deviation : 0.001;

        // for point in line segment.
        if (deviation > 0) {
            if (pointInLineSegment(a, b, c, deviation)) {
                return ((c.x == a.x && c.y == a.y) || (c.x == b.x && c.y == b.y)) ? null : { x: c.x, y: c.y };
            }
            if (pointInLineSegment(a, b, d, deviation)) {
                return ((d.x == a.x && d.y == a.y) || (d.x == b.x && d.y == b.y)) ? null : { x: d.x, y: d.y };
            }
            if (pointInLineSegment(c, d, a, deviation)) {
                return ((a.x == c.x && a.y == c.y) || (a.x == d.x && a.y == d.y)) ? null : { x: a.x, y: a.y };
            }
            if (pointInLineSegment(c, d, b, deviation)) {
                return ((b.x == c.x && b.y == c.y) || (b.x == d.x && b.y == d.y)) ? null : { x: b.x, y: b.y };
            }
        }

        let area_abc = (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x);
        let area_abd = (a.x - d.x) * (b.y - d.y) - (a.y - d.y) * (b.x - d.x);

        if (area_abc * area_abd > 0) {
            return null;
        }

        let area_cda = (c.x - a.x) * (d.y - a.y) - (c.y - a.y) * (d.x - a.x);
        let area_cdb = area_cda + area_abc - area_abd;
        if (area_cda * area_cdb > 0) {
            return null;
        }

        if (area_abd - area_abc === 0) {
            return null;
        }

        let t = area_cda / (area_abd - area_abc);
        let dx = t * (b.x - a.x),
            dy = t * (b.y - a.y);

        return { x: a.x + dx, y: a.y + dy };
    }
    win.intersectLineSegments = intersectLineSegments;

    /** 
     * If two Line Segment overlap.
     * @param {point} a - Line1 point start.
     * @param {point} b - Line1 point end.
     * @param {point} c - Line2 point start.
     * @param {point} d - Line2 point end.
     * @param {number} [deviation=0.001] The deviation for point in line segment.
     * @param {number} [kDeviation=0.001] The k deviation for point in line segment.
     * @return {boolean}
     */
    function lineSegmentOverlap(a, b, c, d, deviation, kDeviation) {
        deviation = (deviation !== undefined) ? deviation : 0.001;
        kDeviation = (kDeviation !== undefined) ? kDeviation : 0.001;

        let kab, kcd;

        if (b.x == a.x) {
            kab = Infinity;
        } else {
            kab = (b.y - a.y) / (b.x - a.x);
        }

        if (c.x == d.x) {
            kcd = Infinity;
        } else {
            kcd = (d.y - c.y) / (d.x - c.x);
        }

        if (Math.abs(Math.abs(kab) - Math.abs(kcd)) > kDeviation) {// Math.abs(Infinity)-Math.abs(Infinity)=NaN,Infinity-10>>num
            // if (Math.abs(kab) == Infinity || Math.abs(kcd) == Infinity) {
            //     console.log(pointToLineDistance(c, d, b))
            //     return (pointToLineDistance(c, d, b) < deviation);
            // }
            return false;
        }

        if (pointInLineSegment(a, b, c, deviation, false) || pointInLineSegment(a, b, d, deviation, false) || pointInLineSegment(c, d, a, deviation, false) || pointInLineSegment(c, d, b, deviation, false)) {
            return true;
        }

        return false;
    }
    win.lineSegmentOverlap = lineSegmentOverlap;

    /** 
     * If two Line intersect. 
     * Before calling this, make sure the two line segments not Collinear.
     * Refference: http://fins.iteye.com/blog/1522259
     * @param {point} a - Line1 point start.
     * @param {point} b - Line1 point end.
     * @param {point} c - Line2 point start.
     * @param {point} d - Line2 point end.
     * @return {boolean}
     */
    function intersectLine(a, b, c, d){  
        // 如果分母为0 则平行或共线, 不相交  
        let denominator = (b.y - a.y)*(d.x - c.x) - (a.x - b.x)*(c.y - d.y);  
        if (denominator==0) {  
            return false;  
        }
           
        // 线段所在直线的交点坐标 (x , y)      
        let x = ( (b.x - a.x) * (d.x - c.x) * (c.y - a.y) + (b.y - a.y) * (d.x - c.x) * a.x - (d.y - c.y) * (b.x - a.x) * c.x ) / denominator ;  
        let y = -( (b.y - a.y) * (d.y - c.y) * (c.x - a.x) + (b.x - a.x) * (d.y - c.y) * a.y - (d.x - c.x) * (b.y - a.y) * c.y ) / denominator;  
        return { x: x, y: y};
    }
    win.intersectLine = intersectLine;
    /** 
     * Set point to an array, which have no Duplicate points. 
     * @param {point[]} array - Array of points.
     * @param {point} point - The insert point.
     * @return {number} - Index of the insert point.
     */
    function setPointArray(array, point) {
        let x = point.x, y = point.y;
        let i;
        for (i = 0; i < array.length; i++) {
            if (array[i][0] === x && array[i][1] === y) {
                return i;
            }
        }

        array.push([x, y]);
        return i;
    }
    win.setPointArray = setPointArray;

    function Ka(a, b) {
        if (0 === a) return 0 < b ? 90 : 0 > b ? 270 : 0; if (0 === b) return 0 < a ? 0 : 180; if (isNaN(a) || isNaN(b)) return 0; let c = 180 * Math.atan(Math.abs(b / a)) / Math.PI; 0 > a ? c = 0 > b ? c + 180 : 180 - c : 0 > b && (c = 360 - c); return c;
    }

    /** 
     * Get line angle.
     * @param {point} a - Line point start.
     * @param {point} b - Line point end.
     * @return {number} - Angle of the line.
     */
    function getLineAngle(a, b) {
        return Ka(b.x - a.x, b.y - a.y);
    }
    win.getLineAngle = getLineAngle;

})(window);